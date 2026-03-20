#!/usr/bin/env make

.DEFAULT_GOAL := default

.PHONY: build-image check clean doctor format help images list-tools lock py-version run run-container sync test test-container version

MCP      := uv run python
PYTHON   := uv run python
RUFF     := uv run ruff
TY       := uv run ty
PYTEST   := uv run python -m pytest
DOCKER   ?= docker
PROJECT_NAME ?= mcp-debian
CTAGS    := $(shell command -v ctags 2>/dev/null)

SRCS     := $(shell find . -name "*.py" -not -path "./.venv/*")

default:	format check test ## default goal (format, check, and test code)

all:	format check test run ## check cover run test doc dist

help: ## display this help
	@echo "Default goal: ${.DEFAULT_GOAL}"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo
	@echo "To initialize and install dependencies managed by uv:"
	@echo
	@echo "uv sync"
	@echo
	@echo "To run commands in the virtual environment:"
	@echo
	@echo "uv run <command>"
	@echo
	@echo "MCP server command (stdio):"
	@echo "  uv run python server.py"
	@echo
	@echo "MCP server command (Docker, stdio):"
	@echo "  make build-image"
	@echo "  docker run --rm -i -v \"$$(pwd):/workspace:ro\" mcp-debian"

sync: ## install/update dependencies from lockfile
	uv sync

lock: ## regenerate lockfile from pyproject
	uv lock

format: ## format code and sort imports
	# format and sort code using ruff
	$(RUFF) check --fix $(SRCS)
	$(RUFF) format $(SRCS)

check: ## check style and lint code
ifdef CTAGS
	# ctags for vim
	ctags --recurse -o tags $(SRCS)
endif
	# format and check code using ruff
	$(RUFF) check $(SRCS)
	$(RUFF) format --check $(SRCS)
	# type check with ty
	$(TY) check $(SRCS)

test: ## run unit tests
	$(PYTEST) -v --cov-report term-missing tests/

run: ## run MCP runtime smoke test
	$(MCP) -c "from mcp.server.fastmcp import FastMCP; print('mcp runtime ok')"

list-tools: ## show MCP tool names
	$(MCP) -c "from server import mcp; print(*[t.name for t in mcp._tool_manager.list_tools()], sep='\n')"

mcp-version: ## display MCP package version information
	$(MCP) -c "import importlib.metadata as m; print("mcp", m.version('mcp'))"

build-image: ## build the Docker image
	@$(DOCKER) build -t $(PROJECT_NAME) .

run-container: build-image ## test server tools: list tests/ and read README.md
	@$(DOCKER) run --rm \
		-v "$(CURDIR):/workspace:ro" \
		--entrypoint /app/.venv/bin/python \
		$(PROJECT_NAME) -c 'from server import list_directory, read_file; print("== list_directory: /workspace/tests =="); print(*list_directory("/workspace/tests"), sep="\n"); print("\n== read_file: /workspace/README.md (first 200 chars) =="); print(read_file("/workspace/README.md")[:200])'

test-container: build-image ## test the Docker image: verify server module loads and tools are registered
	@$(DOCKER) run --rm \
		--entrypoint /app/.venv/bin/python \
		$(PROJECT_NAME) -c 'from server import mcp, list_directory, read_file; tools = [t.name for t in mcp._tool_manager.list_tools()]; print("Tools registered:"); print(*tools, sep="\n")'

images: ## list local images for this project
	@$(DOCKER) image ls $(PROJECT_NAME)

doctor: ## show Docker context, builder, and project images
	@echo "== Docker context =="
	@$(DOCKER) context show
	@echo
	@echo "== Docker contexts =="
	@$(DOCKER) context ls
	@echo
	@echo "== Buildx builders =="
	@$(DOCKER) buildx ls
	@echo
	@echo "== Project images =="
	@$(DOCKER) image ls $(PROJECT_NAME)

clean: ## delete all generated files
	$(RM) -r tags .ruff_cache .pytest_cache **/*.pyc **/*.pyo **/__pycache__
