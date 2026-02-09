# Use uv Python image
FROM ghcr.io/astral-sh/uv:python3.12-bookworm

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
      iproute2 \
      can-utils \
      net-tools \
      kmod \
      build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /app

WORKDIR /app

ENV UV_NO_DEV=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    PATH="/app/.venv/bin:$PATH"

# Copy Python lockfiles and install dependencies first (caching)
COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-install-project

COPY . .

RUN uv sync --locked

RUN chmod +x entrypoint.sh

# Runtime
ENTRYPOINT ["./entrypoint.sh"]
CMD ["python", "main.py", "vcan0", "./dbc-files/canmod-gps.dbc"]
