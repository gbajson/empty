#!/usr/bin/env bash
set -Eeuo pipefail

# Require Bash 5.x or higher
if [ "${BASH_VERSINFO[0]}" -lt 5 ]; then
  echo "Error: This script requires Bash 5.x or higher. You are using Bash $BASH_VERSION."
  exit 1
fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
gitroot=$(readlink -f ./"$(git rev-parse --show-cdup)")
image=$(basename "$gitroot")
gcp_project="some-project-00000"
gcr="eu.gcr.io"
aws_account="00000000000"
aws_region="eu-west-1"
push_aws="False"
push_gcp="False"
push_ghcr="True"
build="True"
use_gha="False"
build_devcontainer="False"
tag=""
plain=0
verbose=0

trap on_error ERR
on_error() {
  echo
  echo "########################"
  echo "#### SCRIPT FAILED. ####"
  echo "########################"
}

VARS=$(python3 - "$@" << EOF
import argparse
import shlex
parser = argparse.ArgumentParser(prog="$0", formatter_class=argparse.ArgumentDefaultsHelpFormatter)

# Add arguments here
parser.add_argument('-v', '--verbose', action='count', default=$verbose)
parser.add_argument('-i', '--image', required=False, default="$image", help="Image to build.")
parser.add_argument('--gcp-project', required=False, default="$gcp_project", help="GCP project id.")
parser.add_argument('--gcr', required=False, default="$gcr", help="GCR")
parser.add_argument('--aws-account', required=False, default="$aws_account", help="AWS account")
parser.add_argument('--aws-region', required=False, default="$aws_region", help="AWS account")
parser.add_argument('-t', '--tag', action='append', required=True, help="Add tag(s) to image.")
parser.add_argument('--plain', action='count', default=$plain, help="Display plain output")
parser.add_argument('--build', action=argparse.BooleanOptionalAction, default=$build, help="Build image.")
parser.add_argument('--build-devcontainer', action=argparse.BooleanOptionalAction, default=$build_devcontainer, help="Build devcontainer image.")
parser.add_argument('--push-gcp', action=argparse.BooleanOptionalAction, default=$push_gcp, help="Push to GCP Arfifact Registry.")
parser.add_argument('--push-aws', action=argparse.BooleanOptionalAction, default=$push_aws, help="Push to AWS ECR.")
parser.add_argument('--push-ghcr', action=argparse.BooleanOptionalAction, default=$push_ghcr, help="Push to GitHub Container Registry.")
parser.add_argument('--use-gha', action=argparse.BooleanOptionalAction, default=$use_gha, help="Use GitHub Actions cache.")

args = parser.parse_args()
for k, v in vars(args).items():
    if isinstance(v, list):
        print("{}=({})".format(k, " ".join(shlex.quote(str(i)) for i in v)))
    else:
        print("{}={}".format(k, shlex.quote(str(v))))
EOF
)
if echo "$VARS" | grep -q "^usage:"; then
  echo "$VARS"
  exit 1
fi
eval "$VARS"
[[ $verbose -gt 0 ]] && set -x
if [[ "$plain" -gt 0 ]]; then progress="plain"; else progress="tty"; fi

# shellcheck disable=SC2091
# $("$script_dir"/setup-pip.sh -d --aws-account "$aws_account" --aws-region "$aws_region")

# shellcheck disable=SC2091
# $("$script_dir"/setup-uv.sh -d --aws-account "$aws_account" --aws-region "$aws_region")

commit=$(git rev-parse HEAD)
declare -rx commit

# https://docs.docker.com/build/cache/backends/gha/
gha_args=()
if [[ "$use_gha" == "True" ]]; then
  # shellcheck disable=SC2054
  gha_args=(
    --cache-from type=gha,scope="$image"
    --cache-to type=gha,mode=max,scope="$image"
  )
fi

ecr="$aws_account.dkr.ecr.$aws_region.amazonaws.com"

# aws ecr get-login-password --region "$aws_region" | \
#   docker login --username AWS --password-stdin "$ecr"

if [[ "$build_devcontainer" == "True" ]]; then
  sudo npm install -g @devcontainers/cli
  (
    cd "$script_dir"
    devcontainer build --workspace-folder . --image-name "$image:$commit"
  )
elif [[ "$build" == "True" ]]; then
  (
    # CACHEBUST=$(echo -n "$CODEARTIFACT_AUTH_TOKEN" | shasum -a 256 | awk '{print $1}')
    CACHEBUST="not-used"

    # shellcheck disable=SC2046
    DOCKER_BUILDKIT=1 docker build \
      --build-arg CACHEBUST="$CACHEBUST" \
      --secret id=codeartifact_auth_token,env=CODEARTIFACT_AUTH_TOKEN \
      --secret id=codeartifact_auth_token_refresh_ts,env=CODEARTIFACT_AUTH_TOKEN_REFRESH_TS \
      "${gha_args[@]}" \
      --progress="$progress" \
      --build-arg GIT_COMMIT="${commit}" \
      $(for t in "${tag[@]}"; do echo -t "$image:$t"; done) \
      "$gitroot"
  )
fi

if [[ "$push_gcp" == "True" ]]; then
  for t in "${tag[@]}"; do
    docker tag "$image:$t" "$gcr/$gcp_project/$image:$t"
    docker push "$gcr/$gcp_project/$image:$t"
  done
fi

if [[ "$push_aws" == "True" ]]; then
  for t in "${tag[@]}"; do
    docker tag "$image:$t" "$ecr/$image:$t"
    docker push "$ecr/$image:$t"
  done
fi

if [[ "$push_ghcr" == "True" ]]; then
  # gh auth refresh -h github.com -s write:packages,read:packages
  # export CR_PAT=$(gh auth token)
  # echo $CR_PAT | docker login ghcr.io -u gbajson --password-stdin
  echo "$PAT_GHCR" | docker login ghcr.io -u gbajson --password-stdin


  registry=ghcr.io/gbajson

  for t in "${tag[@]}"; do
    docker tag "$image:$t" "$registry/$image:$t"
    docker push "$registry/$image:$t"
  done
fi
