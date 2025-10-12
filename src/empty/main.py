"""Empty module."""

import asyncio


async def add(n: float, m: float) -> float:
    """Add two floats."""
    return n + m


async def main() -> None:
    """Main."""
    print("Hello from empty!")


if __name__ == "__main__":
    asyncio.run(main())
