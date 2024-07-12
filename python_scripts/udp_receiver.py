import socket
import time
import os
from dataclasses import dataclass
import numpy as np


def int_to_twos_complement_string(num):
    if num >= 0:
        binary = bin(num)[2:].zfill(32)
        binary_with_spaces = " ".join(binary[i : i + 8] for i in range(0, 32, 8))
    else:
        positive_num = abs(num) - 1
        binary = bin(positive_num)[2:].zfill(32)
        inverted_binary = "".join("1" if bit == "0" else "0" for bit in binary)
        binary_with_spaces = " ".join(
            inverted_binary[i : i + 8] for i in range(0, 32, 8)
        )
    binary_with_spaces = binary_with_spaces[:26] + binary_with_spaces[27:]
    return binary_with_spaces


def int_to_twos_complement_string_16bit(num):
    if num >= 0:
        binary = bin(num)[2:].zfill(32)
    else:
        positive_num = abs(num) - 1
        binary = bin(positive_num)[2:].zfill(32)
    binary = binary[16:]
    return binary


@dataclass
class Data:
    header: int
    sampelCounter: int
    mic: np.ndarray  # Array to hold all microphone data

    @staticmethod
    def from_buffer_copy(buffer, nr_arrays):
        num_mics = nr_arrays * 64
        dtype = np.dtype(
            [
                ("header", np.int32),
                ("sampelCounter", np.int32),
                ("mic", np.int32, num_mics),
            ]
        )
        data = np.frombuffer(buffer, dtype=dtype)[0]
        return Data(
            header=data["header"], sampelCounter=data["sampelCounter"], mic=data["mic"]
        )

    def to_bytes(self):
        header_bytes = int(self.header).to_bytes(4, byteorder="little", signed=True)
        sampelCounter_bytes = int(self.sampelCounter).to_bytes(
            4, byteorder="little", signed=True
        )
        mic_bytes = self.mic.tobytes()
        return header_bytes + sampelCounter_bytes + mic_bytes


UDP_IP = "0.0.0.0"
UDP_PORT = 21875

print("Enter a filename for the recording: ")
fileChooser = input()

print("Save as txt? (y) ")
txtInput = input()

print("Enter time to record (seconds): ")
recordTime = input()

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))

# Receive the first packet to determine the number of arrays
data = sock.recv(1458)
header = int.from_bytes(data[:4], byteorder="little", signed=True)
nr_arrays = (header >> 16) & 0xFF

num_mics = nr_arrays * 64
print(f"Detected number of arrays: {nr_arrays}")

t_end = time.time() + int(recordTime)

ROOT = os.getcwd()

if txtInput.lower() == "y":
    print("Recording!!")
    with open(fileChooser + ".txt", "w") as f:
        while time.time() < t_end:
            data = sock.recv(1458)
            d = Data.from_buffer_copy(data, nr_arrays)
            f.write(
                f"header: {d.header} {int_to_twos_complement_string(d.header)}        "
            )
            f.write(
                f"sampelCounter: {d.sampelCounter} {int_to_twos_complement_string_16bit(d.sampelCounter)}        "
            )
            for i in range(min(num_mics, 212)):  # max 212 mic in txt file
                mic_data = int_to_twos_complement_string(d.mic[i])
                f.write(f"mic_{i}: {mic_data}    ")
            f.write("\n")
else:
    print("Recording")
    with open(fileChooser, "wb") as f:
        while time.time() < t_end:
            data = sock.recv(1458)
            d = Data.from_buffer_copy(data, nr_arrays)
            f.write(d.to_bytes())

print("Done!")
