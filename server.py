import pathlib
import tomllib

from mcp.server.fastmcp import FastMCP


def get_project_version() -> str:
    """Get the version declared for this project.

    Returns:
        The project version from `pyproject.toml`, or `"unknown"` if it
        cannot be determined.
    """
    pyproject_path = pathlib.Path(__file__).with_name("pyproject.toml")
    try:
        with pyproject_path.open("rb") as file:
            pyproject = tomllib.load(file)
        return str(pyproject["project"]["version"])
    except (OSError, tomllib.TOMLDecodeError, KeyError, TypeError):
        return "unknown"


PROJECT_VERSION = get_project_version()
SERVER_INSTRUCTIONS = (
    f"Perform tasks on Debian-based systems. Server version: {PROJECT_VERSION}."
)

# Create an MCP server with the FastMCP wrapper
mcp = FastMCP("mcp-debian", SERVER_INSTRUCTIONS)


@mcp.tool()
def list_directory(path: str) -> list[str]:
    """List the contents of a directory.

    Args:
        path: The absolute path of the directory to list.

    Returns:
        A list of file and directory names in the specified path.
    """
    try:
        return [p.name for p in pathlib.Path(path).iterdir()]
    except OSError as e:
        return [f"Error listing directory: {e}"]


@mcp.tool()
def read_file(path: str) -> str:
    """Read the contents of a file.

    Args:
        path: The absolute path of the file to read.

    Returns:
        The content of the file as a string.
    """
    try:
        return pathlib.Path(path).read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError) as e:
        return f"Error reading file: {e}"


@mcp.tool()
def get_os_version() -> str:
    """Get the raw Debian version information from /etc/os-release.

    Returns:
        The contents of /etc/os-release as a string.
    """
    return read_file("/etc/os-release")


@mcp.tool()
def get_server_version() -> str:
    """Get the version of this MCP server project.

    Returns:
        The version string from `pyproject.toml`.
    """
    return f"server {PROJECT_VERSION}"


if __name__ == "__main__":
    # This runs the server using standard input/output when executed directly
    mcp.run()
