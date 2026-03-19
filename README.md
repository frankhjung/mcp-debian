# MCP Debian Server

This is a demonstration MCP project for interacting with a Debian-based system.

## Model Context Protocol (MCP)

The **Model Context Protocol (MCP)** is often called the "USB-C for AI." It was
introduced by Anthropic to solve the fragmentation that occurs when you try to
give AI models access to your local files, databases, or third-party services.

Here is a breakdown of how it differs from traditional web standards and why it
exists.

## 1. What problem is MCP trying to solve?

MCP solves the **Isolation Problem**.

Most LLMs are "trapped" in a box—they only know what they were trained on. To
make them useful, we try to give them access to our data (Gmail, Slack, GitHub,
local files). Before MCP, every time a new AI came out, every company had to
rebuild their "connectors."

**MCP creates a universal interface** so that:

* **Tool Providers** (Google, Slack, etc.) only have to build one MCP server.
* **AI Developers** (Anthropic, OpenAI, etc.) only have to build one MCP client.
* **Users** can plug any tool into any AI instantly.

## 2. What does MCP offer that Swagger (OpenAPI) doesn’t?

While **Swagger/OpenAPI** is a way to *document* an API so a human developer
knows how to write code for it, **MCP** is a way for an AI to *negotiate its own
capabilities* at runtime.

| Feature       | Swagger / OpenAPI            | Model Context Protocol (MCP)            |
| :---          | :---                         | :---                                    |
| **Primary User**  | Human Developers             | AI Models / Agents                      |
| **Discovery**     | Static (read the docs)       | Dynamic (AI asks: "What can you do?")   |
| **Context**       | Stateless (request/response) | Stateful (maintains session & context)  |
| **Content Types** | Data only (JSON/XML)         | Tools, Read-only Resources, and Prompts |
| **Integration**   | Design-time (hard-coded)     | Runtime (plug-and-play)                 |

**Key Advantage:** In Swagger, if you add a new endpoint, a developer must write
new code to use it. In MCP, if you add a new tool to the server, the LLM
immediately "sees" it and can start using it without any code changes to the
host application.

## 3. Why is MCP different from a standard API?

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

## 4. Why can’t LLMs use APIs directly?

Technically, they can (via "Function Calling"), but it’s brittle and inefficient
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

Sync the project with:

```bash
uv sync
```

Run with:

```bash
uv run mcp-debian
```

## Development

The project includes a `Makefile` for common development tasks:

* `make format`: Format code and sort imports using `ruff`.
* `make check`: Run linting and type checking (`ruff`, `ty`).
* `make test`: Run unit tests with `pytest`.
* `make clean`: Clean up temporary files.

## Add MCP Server to VSCode

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
  `uv --directory /path/to/mcp-debian run mcp-debian`. Give your server a
  descriptive name (e.g., `mcp-debian`). Choose where to save the configuration
  (User or Workspace settings). Workspace is recommended for project-specific
  configurations and security best practices. This creates a `.vscode/mcp.json`
  file.

* **Start and Verify the Server:** Once the configuration is saved, a "Start" or
  "Restart" button should appear inline in the `.vscode/mcp.json` file, or you
  can use the command palette to run `uv runMCP: List Servers`, select your
  server, and choose Start.

* **List Server:** You can list all configured servers using the command palette
  with `MCP: List Servers`. This will show you the status of each server
  (running or stopped). It will also provide options to start, stop, or restart
  each server directly from the list.

* **Use with GitHub Copilot Chat:** Open the Chat view (Ctrl+Alt+I). You can
  explicitly mention a tool in your prompt by typing `#` followed by the tool
  name, or the AI agent will automatically detect and suggest using the
  available tools from your local MCP server. You will be prompted for
  confirmation before the tool is run.

## Dependencies

### uv

This project is using the following tools from
[astral](https://docs.astral.sh/):

* [ruff](https://docs.astral.sh/ruff) for linting and formatting code
* [ty](https://docs.astral.sh/ty) for type checking
* [uv](https://docs.astral.sh/uv/) for building and running the project

## Resources

* [Introduction to MCP](https://modelcontextprotocol.io/introduction)
* [MCP Protocol](https://docs.cursor.com/context/model-context-protocol)
* [Discord](https://discord.com/channels/1348850613705904179/1348850614896951298)
* [Udemy: MCP Crash Course: Complete Model Context Protocol in a Day](https://www.udemy.com/course/model-context-protocol/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file
for details.
