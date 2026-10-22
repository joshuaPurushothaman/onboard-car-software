#!/bin/bash
set -e

# curl -LsSf https://astral.sh/uv/install.sh | sh

apt-get update
apt-get install -y --no-install-recommends \
      iproute2 \
      can-utils \
      net-tools \
      kmod \
      build-essential

# pip install -r requirements.txt
uv sync
