# MCP Debian Server

This is a demonstration MCP project for interacting with a Debian-based system.

## Model Context Protocol (MCP)

The **Model Context Protocol (MCP)** is often called the "USB-C for AI." It was
introduced by Anthropic to solve the fragmentation that occurs when you try to
give AI models access to your local files, databases, or third-party services.

Here is a breakdown of how it differs from traditional web standards and why it
exists.

### What problem is MCP trying to solve?

MCP solves the **Isolation Problem**.

Most LLMs are "trapped" in a box—they only know what they were trained on. To
make them useful, we try to give them access to our data (Gmail, Slack, GitHub,
local files). Before MCP, every time a new AI came out, every company had to
rebuild their "connectors."

**MCP creates a universal interface** so that:

* **Tool Providers** (Google, Slack, etc.) only have to build one MCP server.
* **AI Developers** (Anthropic, OpenAI, etc.) only have to build one MCP client.
* **Users** can plug any tool into any AI instantly.

### What does MCP offer that Swagger (OpenAPI) doesn't?

While **Swagger/OpenAPI** is a way to *document* an API so a human developer
knows how to write code for it, **MCP** is a way for an AI to *negotiate its own
capabilities* at runtime.

| Feature           | Swagger / OpenAPI            | Model Context Protocol (MCP)            |
| :---              | :---                         | :---                                    |
| **Primary User**  | Human Developers             | AI Models / Agents                      |
| **Discovery**     | Static (read the docs)       | Dynamic (AI asks: "What can you do?")   |
| **Context**       | Stateless (request/response) | Stateful (maintains session & context)  |
| **Content Types** | Data only (JSON/XML)         | Tools, Read-only Resources, and Prompts |
| **Integration**   | Design-time (hard-coded)     | Runtime (plug-and-play)                 |

**Key Advantage:** In Swagger, if you add a new endpoint, a developer must write
new code to use it. In MCP, if you add a new tool to the server, the LLM
immediately "sees" it and can start using it without any code changes to the
host application.

### Why is MCP different from a standard API?

A standard API (like REST) is a **fixed contract** between two programs. MCP is
a **communication layer** that sits *on top* of APIs to make them "AI-legible."

* **Standard APIs** are like specific tools (a hammer, a screwdriver). You have
  to know exactly which one to pick and how to swing it.

* **MCP** is like a robotic arm that already knows how to use every tool in the
  shed. You just tell the arm "fix the door," and it figures out which tools to
  pick up.

MCP uses **JSON-RPC 2.0** to allow bidirectional talk. This means the server
doesn't just wait for a request; it can also send "notifications" or "resource
updates" to the AI, keeping the model's "memory" or context updated in
real-time.

### Why can't LLMs use APIs directly?

Technically, they can (via "Function Calling"), but it's brittle and inefficient
for three main reasons:

1. **The "N × M" Problem:** If you have 5 AI apps and 10 data sources, you have
   to write 50 custom integrations. MCP reduces this to $5 + 10$ (every app and
   every source just needs to speak one language: MCP).

2. **Lack of "Common Sense":** A standard API might return a `404 Error` or a
   massive JSON blob. A raw LLM doesn't always know what to do with that. MCP
   servers act as translators, turning complex API responses into structured
   "Context" that the model can actually reason with.

3. **Security & Headers:** LLMs cannot "type" HTTP headers, manage OAuth tokens,
   or handle cookies. MCP abstracts the "plumbing" (auth, transport, error
   handling) so the LLM only deals with the logic.

## Quick start

### MCP tools provided by this server

This server currently exposes the following tools:

* `list_directory(path: str) -> list[str]`: Lists names in a directory path.
* `read_file(path: str) -> str`: Reads a UTF-8 text file.
* `get_os_version() -> str`: Reads `/etc/os-release` and returns its raw
  contents.
* `get_server_version() -> str`: Returns the version declared for this MCP
  server in `pyproject.toml`. The same version is also included in the server's
  MCP instructions at startup.

To list tools from the running project:

```bash
make list-tools
```

### Use uv to sync and run the server

Sync the project with:

```bash
uv sync
```

Run with:

```bash
uv run python server.py
```

### Check the MCP server version

The MCP server reads its project version from `pyproject.toml` at startup and
makes it available through the `get_server_version()` MCP tool.

To check it locally from Python:

```bash
uv run python -c "import server; print(server.get_server_version())"
```

Or via the `Makefile`:

```bash
make mcp-version      # installed mcp package version
make project-version  # project version only
make host-version     # host OS version
make version          # MCP + project + host version info
```

From an MCP client, call:

```text
get_server_version()
```

## Development

### Using the Makefile

The project includes a `Makefile` for common development tasks:

* `make format`: Format code and sort imports using `ruff`.
* `make check`: Run linting and type checking (`ruff`, `ty`).
* `make test`: Run unit tests with `pytest`.
* `make clean`: Clean up temporary files.

Other useful targets:

* `make sync`: Install or update dependencies from `uv.lock`.
* `make lock`: Regenerate `uv.lock` from `pyproject.toml`.
* `make update`: List outdated packages, upgrade dependency versions in the
  lockfile, and sync the environment.
* `make list-tools`: List registered MCP tools from the server.
* `make mcp-version`: Print the installed `mcp` package version.
* `make project-version`: Print this project's version from `pyproject.toml`.
* `make host-version`: Print the host OS version.
* `make run`: Run a lightweight MCP runtime smoke test.

### Update the project version

To bump the project version, update the `version` field under `[project]` in
`pyproject.toml`:

```toml
[project]
version = "0.3.0"
```

Then refresh the lockfile and verify the change:

```bash
uv lock
rg -n '^version = ' pyproject.toml
```

> Note: `uv.lock` may still contain other `0.2.0` entries for third-party
> dependencies. That does not mean the `mcp-debian` project version failed to
> update.

Run the makefile targets to print version information:

```bash
make project-version  # project version (from pyproject.toml)
make mcp-version      # installed mcp package version
make host-version     # host OS version
make version          # all version info together
```

### Add MCP Server to VSCode

Steps to Configure a Local MCP Server in VS Code Ensure Prerequisites:

* Have the latest version of
  [Visual Studio Code](https://code.visualstudio.com/) installed. Ensure the
  [GitHub Copilot Chat extension](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat)
  is installed and enabled. Have the necessary runtime installed for your
  specific MCP server (e.g., Python).

* **Add the Server Configuration:** Open the Command Palette in VS Code by
  pressing `Ctrl+Shift+P`.

* **Run the command MCP:** Add Server. Select `Command (stdio)` as the transport
  mechanism for a local server. Enter the absolute command to run your server:
  `uv --directory /path/to/mcp-debian run python server.py`. Give your server a
  descriptive name (e.g., `mcp-debian`). Choose where to save the configuration
  (User or Workspace settings). Workspace is recommended for project-specific
  configurations and security best practices. This creates a `.vscode/mcp.json`
  file.

* **Start and Verify the Server:** Once the configuration is saved, a "Start" or
  "Restart" button should appear inline in the `.vscode/mcp.json` file, or you
  can use the command palette to run `MCP: List Servers`, select your server,
  and choose Start.

* **List Server:** You can list all configured servers using the command palette
  with `MCP: List Servers`. This will show you the status of each server
  (running or stopped). It will also provide options to start, stop, or restart
  each server directly from the list.

* **Use with GitHub Copilot Chat:** Open the Chat view (Ctrl+Alt+I). You can
  explicitly mention a tool in your prompt by typing `#` followed by the tool
  name, or the AI agent will automatically detect and suggest using the
  available tools from your local MCP server. You will be prompted for
  confirmation before the tool is run.

  * **prompt:**

    `#mcp-debian list the directories in the current workspace`

  * **response:**

    Consifered using MCP tool for directory listing

    * I need to answer the user's request, and I’m considering using the MCP
      tool to list the directory. The tool reference shows that
      mcp_mcp-debian_list_directory is available, so I should call it with the
      current workspace path. It seems important to mention that I’m using the
      tool since it likely works well for this task. I'll preface the tool call
      with a brief status update before executing it. Let's go ahead and make
      that call!

    Checking the current workspace directory listing via MCP now.

    Ran `list_directory` - mcp-debian (MCP Server)

    ```json
    Completed with input: {
      "path": "/home/frank/dev/mcp/debian"
    }
    ```

    Here are the directories/files in the current workspace:

    * `.python-version`
    * `.gitignore`
    * `tests`
    * `.pytest_cache`
    * `mcp.json`
    * `.vscode`
    * `.venv`
    * `server.py`
    * `__pycache__`
    * `Makefile`
    * `.ruff_cache`
    * `README.md`
    * `.github`
    * `tags`
    * `.mypy_cache`
    * `uv.lock`
    * `Dockerfile`
    * `mcp-debian.code-workspace`
    * `LICENSE`
    * `.git`
    * `pyproject.toml`
    * `.dockerignore`

## Dependencies

### uv

This project is using the following tools from
[astral](https://docs.astral.sh/):

* [ruff](https://docs.astral.sh/ruff) for linting and formatting code
* [ty](https://docs.astral.sh/ty) for type checking
* [uv](https://docs.astral.sh/uv/) for building and running the project

## Resources

* [Introduction to MCP (YouTube)](https://youtu.be/7j1t3UZA1TY?si=5Biw4AWTN7Nfywvu)
* [Introduction to MCP](https://modelcontextprotocol.io/introduction)
* [MCP Protocol](https://docs.cursor.com/context/model-context-protocol)
* [Discord](https://discord.com/channels/1348850613705904179/1348850614896951298)
* [Udemy: MCP Crash Course: Complete Model Context Protocol in a Day](https://www.udemy.com/course/model-context-protocol/)
* [Top 10 LLM security risks](https://genai.owasp.org/llm-top-10/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file
for details.
