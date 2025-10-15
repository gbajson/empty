FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS torch
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
ENV UV_PYTHON_DOWNLOADS=0
WORKDIR /app
ARG CACHEBUST
COPY pyproject-torch.toml /app/pyproject.toml
RUN uv lock && uv sync --frozen --no-install-project --no-dev



FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS builder
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
ENV UV_PYTHON_DOWNLOADS=0
WORKDIR /app
RUN mkdir /app/.venv /app/src
COPY --from=torch /app/.venv /app/.venv
COPY pyproject.toml uv.lock /app/
ARG CACHEBUST
RUN uv sync --frozen --no-install-project --no-dev



FROM ghcr.io/gbajson/python-base:3.13.8
WORKDIR /app
RUN mkdir /app/.venv /app/src
COPY --from=builder --chown=user:user /app/.venv /app/.venv
COPY --chown=user:user src /app/src
USER user
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONPATH="/app/src"
EXPOSE 8080
ARG GIT_COMMIT
ENV GIT_COMMIT=$GIT_COMMIT
CMD ["uvicorn", "empty-python.main:app", "--proxy-headers", "--host", "0.0.0.0", "--port", "8080"]
