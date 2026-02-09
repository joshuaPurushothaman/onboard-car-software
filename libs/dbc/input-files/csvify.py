
# )
#   vcan0  009   [8]  80 DD C0 FC AE AC D3 18 ::
# GnssImu(
#     ImuValid: Invalid,
#     AccelerationX: 24.0 m/s^2,
#     AccelerationY: -60.625 m/s^2,
#     AccelerationZ: 60.75 m/s^2,
#     AngularRateX: -168.75 deg/s,
#     AngularRateY: 58.75 deg/s,
#     AngularRateZ: -206.5 deg/s
# )
#   vcan0  009   [8]  80 BC CC FC 9F 47 9D 08 ::
# GnssImu(
#     ImuValid: Invalid,
#     AccelerationX: 8.0 m/s^2,
#     AccelerationY: -13.125 m/s^2,
#     AccelerationZ: 60.75 m/s^2,
#     AngularRateX: 207.75 deg/s,
#     AngularRateY: 212.25 deg/s,
#     AngularRateZ: -239.0 deg/s
# )
#   vcan0  009   [8]  80 BC 4A FC 9F AD D4 F8 ::
# GnssImu(
#     ImuValid: Invalid,
#     AccelerationX: 8.0 m/s^2,
#     AccelerationY: -21.125 m/s^2,
#     AccelerationZ: 60.25 m/s^2,
#     AngularRateX: -48.25 deg/s,
#     AngularRateY: 74.75 deg/s,
#     AngularRateZ: 241.5 deg/s
# )
#   vcan0  010   [8]  15 30 00 00 00 00 00 00 :: Unknown frame id 16 (0x10)
#   vcan0  002   [8]  60 35 74 A2 BF 32 A0 00 :: Wrong data size: 8 instead of 6 bytes
#   vcan0  003   [8]  8A 33 CA 94 ED 9C 89 E0 ::
# GnssPosition(
#     PositionValid: Invalid,
#     Latitude: 84.39789299999998 deg,
#     Longitude: -107.851156 deg,
#     PositionAccuracy: 56 m
# )
#   vcan0  004   [8]  47 BE 32 90 00 00 00 00 :: Wrong data size: 8 instead of 4 bytes
#   vcan0  005   [8]  81 10 E1 9D 1A 82 CD 75 ::
# GnssAttitude(
#     AttitudeValid: Valid,
#     Roll: 31.200000000000017 deg,
#     RollAccuracy: 26.400000000000002 deg,
#     Pitch: 177.90000000000003 deg,
#     PitchAccuracy: 13.4 deg,


# Grab all GnssPosition messages from a CAN log and convert to CSV

# open "decoded_output_for_reference.uhhh"

f = open("decoded_output_for_reference.uhhh", "r")
out = open("gnss_positions.csv", "w")

out.write("Latitude,Longitude\n")

for i, line in enumerate(f):
    unique_letter = "a"
    if "GnssPosition(" in line:
        # GnssPosition(
        #     PositionValid: Invalid,
        #     Latitude: 84.39789299999998 deg,
        #     Longitude: -107.851156 deg,
        #     PositionAccuracy: 56 m
        # )

        # Ignore the PositionValid line
        next(f)
        lat_line = next(f).strip()
        lon_line = next(f).strip()
        # Ignore the PositionAccuracy line
        next(f)
        
        # Parse latitude by finding the colon and " deg"
        lat_start = lat_line.index(":") + 1
        lat_end = lat_line.index("deg")
        latitude = lat_line[lat_start:lat_end].strip()

        # Parse longitude by finding the colon and " deg"
        lon_start = lon_line.index(":") + 1
        lon_end = lon_line.index("deg")
        longitude = lon_line[lon_start:lon_end].strip()

        # For uniqueness, append a letter that we have not used yet
        unique_letter = chr(ord('a') + (i % 26))

        out.write(f"{latitude},{longitude},{unique_letter}\n")

f.close()
out.close()
