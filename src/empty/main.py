"""Empty module."""

import asyncio


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


async def add(n: float, m: float) -> float:
    """Add two floats."""
    return n + m


async def main() -> None:
    """Main."""
    print("Hello from empty!")


if __name__ == "__main__":
    asyncio.run(main())
