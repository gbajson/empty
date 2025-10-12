"""Tests Configuration."""

import os

import pytest

os.environ["LOG_LEVEL"] = "debug"


@pytest.fixture
def anyio_backend() -> str:
    """Configure anyio backend."""
    return "asyncio"
