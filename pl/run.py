from pathlib import Path
import os
import sys
import subprocess
import time
import threading

# fmt: off
user = os.getenv('USER')
path = f"/home/{user}/Utilities/vunit/"
sys.path.append(path)
from vunit import VUnit # type: ignore
# fmt: on

# NOTE: Path to directory containing this file
ROOT = Path(__file__).parent

vu = VUnit.from_argv()  # Stop using the builtins ahead of time.vu.add_vhdl_builtins() #new for version 5 VUnit
vu.add_vhdl_builtins()  # new for version 5 VUnit

lib = vu.add_library("lib")
# lib.add_source_files(ROOT.glob("test/sample.vhd"))

lib.add_source_files(ROOT.glob("src/axi_full/*.vhd"))
lib.add_source_files(ROOT.glob("src/channelizer/*.vhd"))
lib.add_source_files(ROOT.glob("src/filter/*.vhd"))
lib.add_source_files(ROOT.glob("src/sample_data/*.vhd"))
lib.add_source_files(ROOT.glob("src/simulated_array/*.vhd"))
lib.add_source_files(ROOT.glob("src/simulated_array_v2/*.vhd"))
lib.add_source_files(ROOT.glob("src/ws_pulse/*.vhd"))

lib.add_source_files(ROOT.glob("src/wrappers/aw_top.vhd"))
lib.add_source_files(ROOT.glob("src/wrappers/zynq_bd_wrapper.vhd"))
lib.add_source_files(ROOT.glob("src/matrix_package.vhd"))

lib.add_source_files(ROOT.glob("test/**/*.vhd"))

for l in lib.get_test_benches():
    wave = ROOT.joinpath("test", "wave", f"{l.name}.tcl")
    l.set_sim_option("ghdl.viewer_script.gui", str(wave) if wave.is_file() else str(ROOT / "gtkwave.tcl"))


def wait_for_gtkwave():
    sleep_time = 0.05  # small timer makes it maximize before tb_.tcl scirpt go to full view
    max_wait_time = 2  # max wait time in seconds
    for i in range(int(max_wait_time * (1/sleep_time))):
        # list of open windows
        result = subprocess.run(["wmctrl", "-l"], capture_output=True, text=True)
        # Check if GTKWave is in list
        if "GTKWave" in result.stdout:
            print("GTKWave detected, maximizing window...")
            subprocess.run(["wmctrl", "-r", "GTKWave", "-b", "add,maximized_vert,maximized_horz"])
            break

        time.sleep(sleep_time)


GTKWave = False
if "--gtkwave-fmt" in sys.argv:
    GTKWave = True
    thread = threading.Thread(target=wait_for_gtkwave)
    thread.start()

vu.main()

if GTKWave:
    thread.join()
