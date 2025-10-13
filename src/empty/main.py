"""Empty module."""

import asyncio
from statistics import median
from typing import Any, Protocol, Sequence, TypeVar


class Comparable(Protocol):  # pylint: disable=too-few-public-methods
    """Protocol for Comparable."""

    def __lt__(self, other: Any, /) -> bool: ...
    def __le__(self, other: Any, /) -> bool: ...


T = TypeVar("T", bound=Comparable)


def append_sorted(l1: Sequence[T], l2: Sequence[T]) -> list[T]:
    """Appends two sorted lists."""
    idx_1 = 0
    idx_2 = 0
    len_1 = len(l1)
    len_2 = len(l2)
    n: list[T] = []

    for _ in range(len_1 + len_2):
        if idx_1 == len_1:
            n += l2[idx_2:]
            break
        if idx_2 == len_2:
            n += l1[idx_1:]
            break

        x = l1[idx_1]
        y = l2[idx_2]

        if x <= y:
            n.append(x)
            idx_1 += 1
        else:
            n.append(y)
            idx_2 += 1
    return n


class Solution:
    """https://leetcode.com/problems/longest-substring-without-repeating-characters/"""

    def lengthOfLongestSubstring(self, s: str) -> int:  # pylint: disable=invalid-name
        """
        :type s: str
        :rtype: int
        """

        if len(s) < 2:
            return len(s)

        max_len = 0

        for idx_x, _ in enumerate(s[:-1]):
            seen: set[str] = set()
            for idx_y, y in enumerate(s[idx_x:]):
                if y in seen:
                    break
                seen.add(y)
                max_len = max(max_len, idx_y + 1)

        return max_len

    def lengthOfLongestSubstring_sliding_window(  # pylint: disable=invalid-name
        self, s: str
    ) -> int:
        """
        :type s: str
        :rtype: int
        """

        left = 0
        max_len = 0
        last_index: dict[str, int] = {}

        left = 0
        max_len = 0
        last_index = {}

        for idx, letter in enumerate(s):
            if letter in last_index and last_index[letter] >= left:
                left = last_index[letter] + 1
            last_index[letter] = idx
            max_len = max(max_len, idx - left + 1)
        return max_len

    def findMedianSortedArrays(  # pylint: disable=invalid-name
        self, nums1: list[int], nums2: list[int]
    ) -> float:
        """https://leetcode.com/problems/median-of-two-sorted-arrays/"""
        return float(median(nums1 + nums2))

    def findMedianSortedArrays_append(  # pylint: disable=invalid-name
        self, nums1: list[int], nums2: list[int]
    ) -> float:
        """https://leetcode.com/problems/median-of-two-sorted-arrays/"""
        nums: list[int] = append_sorted(nums1, nums2)

        total = len(nums)
        m = total // 2

        return nums[m] if total % 2 else (nums[m] + nums[m - 1]) / 2


async def add(n: float, m: float) -> float:
    """Add two floats."""
    return n + m


async def main() -> None:
    """Main."""
    print("Hello from empty!")


if __name__ == "__main__":
    asyncio.run(main())
