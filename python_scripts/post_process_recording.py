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
            # Read one full data packet (header + sampleCounter + PL_counter + subband_nr + 64 microphones)
            data_packet = bin_file.read(4 + 4 + 4 + 4 + (64 * 4 * nr_arrays))
            if not data_packet:
                break  # Stop when no more data

            # Unpack the binary data
            header, sample_counter, pl_counter, subband_nr, *mic_data = struct.unpack("<iiii64i", data_packet)

            # Write to text file
            txt_file.write(f"header: {int_to_twos_string_header(header)}    ")
            txt_file.write(f"sample_counter: {sample_counter}    ")
            txt_file.write(f"pl_counter: {pl_counter}    ")
            txt_file.write(f"subband_nr: {subband_nr:03d}    ")

            for i, mic in enumerate(mic_data):
                txt_file.write(
                    f"mic_{i}: {int_to_twos_complement_string(mic)}  ")

            txt_file.write("\n")

    print(f"Conversion complete! Saved as {txt_path}")


def check_all_sample_nr(bin_path):
    """Check that counter is correct and no samples are missed"""
    nr_arrays = 1
    # size of each data packet (header + counter + mic_data)
    data_packet_size = 4 + 4 + 4 + 4 + (64 * 4 * nr_arrays)

    if not os.path.exists(bin_path):
        print(f"Error: File {bin_path} not found!")
        return

    with open(bin_path, "rb") as bin_file:
        # Read the first row
        data_packet = bin_file.read(data_packet_size)

        if not data_packet:
            print("Error: File is empty!")
            return

        header, sample_counter, pl_counter, subband_nr, *mic_data = struct.unpack("<iiii64i", data_packet)

        current_counter = sample_counter
        start_sample_nr = sample_counter
        print(f"Starting counter: {current_counter}")

        while True:
            # Read next data packet (header + sampleCounter + 64 microphones)
            data_packet = bin_file.read(data_packet_size)

            if not data_packet:
                break  # End of file reached

            # Unpack the binary data
            header, sample_counter, pl_counter, subband_nr, *mic_data = struct.unpack("<iiii64i", data_packet)

            if current_counter + 1 == sample_counter:
                current_counter = sample_counter
            else:
                print(f"ERROR in counter! Expected {current_counter + 1}, but found {sample_counter}" +
                      f" (sample: {current_counter - start_sample_nr})" + f" (diff: {sample_counter - current_counter})")

                current_counter = sample_counter

        print("Check complete! All sample counters are in order.")


print("Enter the file to process: ")
file_name = input().strip()

ROOT = os.getcwd()
bin_path = Path(ROOT + "/recorded_data/" + f"{file_name}.bin")
txt_path = Path(ROOT + "/recorded_data/" + f"{file_name}.txt")

check_all_sample_nr(bin_path)
bin_to_txt(bin_path, txt_path)

print(" ")  # end with a empty line
