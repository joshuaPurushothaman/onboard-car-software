# Use Python slim image
FROM python:3.12-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
      iproute2 \
      can-utils \
      net-tools \
      kmod \
      build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .


RUN chmod +x entrypoint.sh

# Runtime
ENTRYPOINT ["./entrypoint.sh"]