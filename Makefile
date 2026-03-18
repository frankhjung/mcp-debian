#!/usr/bin/env make

.DEFAULT_GOAL := default

.PHONY: check clean format help run test

MCP      := uv run --with 'mcp[cli]' python
PYTHON   := uv run python
RUFF     := uv run --with ruff ruff
TY       := uv run --with ty ty
PYTEST   := uv run --with pytest --with pytest-cov python -m pytest
CTAGS    := $(shell command -v ctags 2>/dev/null)

SRCS     := $(shell find . -name "*.py" -not -path "./.venv/*")

default:	format check test version ## default goal

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
	$(MCP) --help

format: ## format code and sort imports
	# format and sort code using ruff
	$(RUFF) check --select I --fix $(SRCS)
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

run: ## run against test data
	$(MCP) -c "from mcp.server.fastmcp import FastMCP; print('mcp runtime ok')"

version: ## display version information
	$(MCP) -c "import importlib.metadata as m; print(m.version('mcp'))"

clean: ## delete all generated files
	$(RM) -r tags **/*.pyc **/*.pyo **/*.py,cover *.pyc *.pyo *.py,cover __pycache__ **/__pycache__
