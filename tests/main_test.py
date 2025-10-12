"""Tests for empty."""

import pytest

from empty.main import add


@pytest.mark.asyncio
async def test_add_float_large_small() -> None:
    """Verify if float works as float."""

    # Given
    n = 10000000000000000000000000000000000000000000000.0
    m = 0.00000000000000000000000000000000000000000000001
    expected = n

    # When
    result = await add(n, m)

    # Than
    assert result == expected


def test_basic_math() -> None:
    """Test"""
    assert 1 + 1 == 2
