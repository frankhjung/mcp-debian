# syntax=docker/dockerfile:1.7
FROM python:3.14-slim

COPY --from=ghcr.io/astral-sh/uv:0.8.22 /uv /uvx /bin/

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install production dependencies only
COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev --no-install-project

# Copy application source
COPY server.py ./

# Run as non-root user
RUN useradd --create-home --shell /bin/bash appuser
USER appuser

ENTRYPOINT ["/app/.venv/bin/python", "server.py"]
