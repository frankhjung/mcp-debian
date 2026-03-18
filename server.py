import os

from mcp.server.fastmcp import FastMCP

# Create an MCP server with the FastMCP wrapper
mcp = FastMCP("LocalFileServer")


@mcp.tool()
def list_directory(path: str) -> list[str]:
    """List the contents of a directory.

    Args:
        path: The absolute path of the directory to list.
    """
    try:
        return os.listdir(path)
    except OSError as e:
        return [f"Error listing directory: {e}"]


@mcp.tool()
def read_file(path: str) -> str:
    """Read the contents of a file.

    Args:
        path: The absolute path of the file to read.
    """
    try:
        with open(path, "r", encoding="utf-8") as f:
            return f.read()
    except (OSError, UnicodeDecodeError) as e:
        return f"Error reading file: {e}"


if __name__ == "__main__":
    # This runs the server using standard input/output when executed directly
    mcp.run()
