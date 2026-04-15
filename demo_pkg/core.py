def greet(name: str = "World", version: str = "") -> str:
    """Return a greeting string."""
    version_str = f" (v{version})" if version else ""
    return f"Hello, {name}!{version_str}"


def get_info(version: str = "") -> dict:
    """Return package metadata."""
    return {
        "name": "demo_pkg",
        "version": version,
        "description": "A simple demo package",
    }
