#/usr/bin/env bash

# i was using this for development and not in the dockerfile
set -oeux

# sudo ip link add dev vcan0 type vcan
# sudo ip link set up vcan0

canplayer -I cleanlap.can vcan0=vcan0 &

uv run main.py vcan0 ./dbc-files/canmod-gps.dbc
