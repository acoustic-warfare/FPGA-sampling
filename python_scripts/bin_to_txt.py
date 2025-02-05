import struct
import os
from pathlib import Path


def int_to_twos_complement_string(num, bits=32):
    """Convert integer to two's complement binary string."""
    if num >= 0:
        binary = bin(num)[2:].zfill(bits)
    else:
        binary = bin((1 << bits) + num)[2:]
    return " ".join(binary[i:i+8] for i in range(0, bits, 8))


def int_to_twos_string_header(num, bits=32):
    """Convert integer to two's complement binary string."""
    if num >= 0:
        binary = bin(num)[2:].zfill(bits)
    else:
        binary = bin((1 << bits) + num)[2:]
    return binary[0:7] + " " + binary[8:15] + " " + binary[16:31]


def bin_to_txt(bin_path, txt_path):
    """Convert binary UDP data file to a readable text format."""
    max_rows = 1000
    nr_arrays = 1

    with open(bin_path, "rb") as bin_file, open(txt_path, "w") as txt_file:
        for row in range(max_rows):
            # Read one full data packet (header + sampleCounter + 64 microphones)
            data_packet = bin_file.read(4 + 4 + (64 * 4 * nr_arrays))
            if not data_packet:
                break  # Stop when no more data

            # Unpack the binary data
            header, sample_counter, * \
                mic_data = struct.unpack("<ii64i", data_packet)

            # Write to text file
            txt_file.write(f"header: {int_to_twos_string_header(header)}    ")
            txt_file.write(f"sample_counter: {sample_counter}    ")

            for i, mic in enumerate(mic_data):
                txt_file.write(
                    f"mic_{i}: {int_to_twos_complement_string(mic)}  ")

            txt_file.write("\n")

    print(f"Conversion complete! Saved as {txt_path}")


print("Enter a filename to samples: ")
fileChooser = input()
# fileChooser = "test"

ROOT = os.getcwd()
bin_path = Path(ROOT + "/recorded_data/" + fileChooser + ".bin")
txt_path = Path(ROOT + "/recorded_data/" + fileChooser + ".txt")

bin_to_txt(bin_path, txt_path)
