FROM python:3.13-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Install production dependencies only
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

# Copy application source
COPY server.py ./

# Run as non-root user
RUN useradd --create-home --shell /bin/bash appuser
USER appuser

ENTRYPOINT ["uv", "run", "python", "server.py"]
