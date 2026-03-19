import pathlib

from mcp.server.fastmcp import FastMCP

# Create an MCP server with the FastMCP wrapper
mcp = FastMCP("mcp-debian", "A simple MCP server for Debian-based systems.")


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


if __name__ == "__main__":
    # This runs the server using standard input/output when executed directly
    mcp.run()
