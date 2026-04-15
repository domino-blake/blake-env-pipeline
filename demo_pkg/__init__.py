from .core import greet as _greet, get_info as _get_info

__version__ = "0.12.0"


def greet(name: str = "World") -> str:
    return _greet(name, version=__version__)


def get_info() -> dict:
    return _get_info(version=__version__)


__all__ = ["greet", "get_info", "__version__"]
