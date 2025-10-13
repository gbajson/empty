"""Empty module."""

import asyncio


async def add(n: float, m: float) -> float:
    """Add two floats."""
    return n + m


# def pair(s: str):
#     a = s.split(",")
#     result = []
#     l = len(a)
#     idx = 0
#     while idx < l:
#         if idx + 1 < l:
#             value = (
#                 int(a[idx]),
#                 int(a[idx + 1]),
#             )
#             result.append(value)
#         idx += 2

#     return result


# # n zarowek (wl, wyl)


# def switch(z, x):
#     l = len(z)
#     if x < 0:
#         return z

#     for y in range(x):
#         idx = 0
#         while idx < l:
#             z[idx] = not (z[idx])
#             idx += y + 1
#     return z


async def main() -> None:
    """Main."""
    # a = [1, 2]

    # assert pair("1, 2, 3, 4") == [(1, 2), (3, 4)]
    # print("ok")

    # n = 100
    # z = [False] * n
    # switch(z, 100)
    # print(z[73])


if __name__ == "__main__":
    asyncio.run(main())


# Movies ( mID, title, year )

# Reviewers ( rID, name )

# Ratings ( rID, mID, score )


# Movies
# mID	title	    year
# -----|---------------
# 11	Star Wars	1977
# 22	The Mask	1994


# Reviewers
# rID	name
# -----|----------------
# 21	Sarah Martinez
# 22	Daniel Lewis


# Ratings
# rID	mID	score
# ---|-------|
# 21	11	9


# Znajdz wszytkie filmy nie oceniane przez Daniel Lewis
# select * from movies m
#  join Reviewers rev
#  outer join ratings rat
# where m.mId = ratings.mID
# minus
# select * from movies
#  join Reviewers rev
#  outer join ratings rat
# where ratings.rId = rev.rId;


# Godziny pracy
# 10.30 -- 11.00
# 15:30 --
