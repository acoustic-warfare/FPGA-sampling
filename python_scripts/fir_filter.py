import numpy as np
from scipy.signal import chirp
import matplotlib.pyplot as plt
import argparse
import os

import subprocess

# Settings
DATA_WIDTH = 16
OFFSET = 1
N = 1000
TEXT_FILE_INPUT = "filter_coefficients/filter_input.txt"
TEXT_FILE_OUTPUT = "filter_coefficients/filter_output.txt"
SHIFT = 5

# Filter coefficients: Equiripple, 60-taps, Default settings
COEFF_HEX = [
    "FFB8",
    "FFA5",
    "FFDA",
    "0041",
    "0033",
    "FF18",
    "FDCB",
    "FE5C",
    "012F",
    "02DD",
    "FF51",
    "F835",
    "F674",
    "0242",
    "189B",
    "2AC8",
    "2AC8",
    "189B",
    "0242",
    "F674",
    "F835",
    "FF51",
    "02DD",
    "012F",
    "FE5C",
    "FDCB",
    "FF18",
    "0033",
    "0041",
    "FFDA",
    "FFA5",
    "FFB8",
]


COEFF_INT = np.array([int(c, 16) for c in COEFF_HEX])


def generate_input():
    Max = 2 ** (DATA_WIDTH - 1) - 1

    # Input Generation
    t = np.linspace(0, 1, N, endpoint=False)
    x = chirp(t, f0=0, f1=250, t1=1, method="linear")
    x_int = np.round(x * Max).astype(int)

    decay = np.zeros(len(COEFF_INT) - 1, dtype=int)
    shift = np.zeros(SHIFT, dtype=int)

    x_hdl = np.concatenate((x_int, decay, shift))

    np.savetxt(TEXT_FILE_INPUT, x_hdl, fmt="%d")

    # Uncomment the following to visualize the impulse response
    impls = np.where(COEFF_INT > 0, np.ceil(COEFF_INT), np.floor(COEFF_INT))
    plt.stem(impls)
    plt.grid()
    plt.xlabel("Sample(n)")
    plt.ylabel("Amplitude")
    plt.ylim([-1.2, 1.2])
    plt.show()

    print("Stimuli file ready! Run HDL simulation!")


def run_vhdl_simulation():
    print("Running VHDL simulation...")
    script_path = os.path.abspath("pl/scripts/other/run_test.sh")
    os.chmod(script_path, 0o755)  # Sets executable permissions (rwxr-xr-x)
    subprocess.run([script_path, "--auto", "tb_fir_filter"])


def process_output():
    Max = 2 ** (DATA_WIDTH - 1) - 1

    # Read input data (x_int) from 'filter_input.txt'
    x_hdl = np.loadtxt(TEXT_FILE_INPUT, dtype=int)

    # Generate reference output
    x_int = x_hdl[
        : len(x_hdl) - SHIFT - (len(COEFF_INT) - 1)
    ]  # Extract the original input data
    y_ref = np.convolve(x_int, COEFF_INT) / (2 ** (DATA_WIDTH - 1))
    y_ref = np.concatenate((np.zeros(SHIFT, dtype=int), y_ref))

    # Read HDL output
    y = np.loadtxt(TEXT_FILE_OUTPUT, dtype=int)

    # Plotting
    plt.figure(figsize=(10, 10))

    plt.subplot(4, 1, 1)
    plt.plot(x_int / (2 ** (DATA_WIDTH - 1)))
    plt.title("Impulse response (input)")
    plt.xlabel("Time(n)")
    plt.ylabel("Normalized Amplitude")
    plt.grid(True)

    plt.subplot(4, 1, 2)
    plt.plot(y_ref / (2 ** (DATA_WIDTH - 1)))
    plt.title("Reference output")
    plt.xlabel("Time(n)")
    plt.ylabel("Normalized Amplitude")
    plt.grid(True)

    plt.subplot(4, 1, 3)
    plt.plot(y / (2 ** (DATA_WIDTH - 1)))
    plt.title("HDL filter output")
    plt.xlabel("Time(n)")
    plt.ylabel("Normalized Amplitude")
    plt.grid(True)

    plt.subplot(4, 1, 4)
    plt.plot((y_ref - y) / (2 ** (DATA_WIDTH - 1)))
    plt.title("Output difference")
    plt.xlabel("Time(n)")
    plt.ylabel("Normalized Amplitude")
    plt.grid(True)

    plt.tight_layout()
    plt.show()


def main():
    # Perform the sequence of actions
    generate_input()
    run_vhdl_simulation()
    process_output()


if __name__ == "__main__":
    main()
