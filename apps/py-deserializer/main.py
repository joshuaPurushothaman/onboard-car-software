#!/usr/bin/env python3
import argparse
import time
import cantools
import can
import redis


def main():
    p = argparse.ArgumentParser(
        description="Listen on a CAN interface and decode messages using a DBC file."
    )
    p.add_argument("interface", help="CAN interface name (e.g. can0 or vcan0)")
    p.add_argument("dbc", help="Path to DBC file")
    args = p.parse_args()

    db = cantools.database.load_file(args.dbc)

    # FIXME: is interface=socketcan always right..?
    bus = can.interface.Bus(channel=args.interface, interface="socketcan")
    print(f"Listening on {args.interface}, decoding with {args.dbc}")

    # Connect to the Redis server (default host='localhost', port=6379, db=0)
    # Since we forward traffic from the container to the host's port 6379, this is okay!
    # [see onboard-car-software/docker-compose.yml for that detail]
    # decode_responses=True ensures responses are strings, not bytes
    r = redis.Redis(decode_responses=True)

    while True:
        # NOTE: Consider swapping recv() for Listener
        msg = bus.recv(timeout=None)

        # decoded = db.decode_message(msg.arbitration_id, msg.data)
        database_message = db.get_message_by_frame_id(
            msg.arbitration_id, msg.is_extended_id
        )

        name = database_message.name
        decoded = database_message.decode_simple(msg.data)

        ts = getattr(msg, "timestamp", time.time())
        print(
            f"{ts:.3f} id=0x{msg.arbitration_id:x} len={len(msg.data)} data={msg.data.hex()} {name=} {decoded=}"
        )

        # print("Publishing to redis...")

        r.publish(channel=name, message=str(decoded))


if __name__ == "__main__":
    main()
