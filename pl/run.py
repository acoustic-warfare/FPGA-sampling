from pathlib import Path

import os
import sys
user = os.getenv('USER')
path = f"/home/{user}/Utilities/vunit/"
sys.path.append(path)

from vunit import VUnit

# NOTE: Path to directory containing this file
ROOT = Path(__file__).parent

vu = VUnit.from_argv()  # Stop using the builtins ahead of time.vu.add_vhdl_builtins() #new for version 5 VUnit
vu.add_vhdl_builtins() #new for version 5 VUnit

lib = vu.add_library("lib")
lib.add_source_files(ROOT.glob("test/**/*.vhd"))
#lib.add_source_files(ROOT.glob("test/sample.vhd"))


lib.add_source_files(ROOT.glob("src/sample_data/*.vhd"))
lib.add_source_files(ROOT.glob("src/ws_pulse/*.vhd"))
lib.add_source_files(ROOT.glob("src/axi_full/*.vhd"))
lib.add_source_files(ROOT.glob("src/simulated_array/*.vhd"))
lib.add_source_files(ROOT.glob("src/filter/*.vhd"))
lib.add_source_files(ROOT.glob("src/wrappers/aw_top.vhd"))
lib.add_source_files(ROOT.glob("src/wrappers/zynq_bd_wrapper.vhd"))
lib.add_source_files(ROOT.glob("src/axi_lite/rd_en_pulse.vhd"))
lib.add_source_files(ROOT.glob("src/matrix_package.vhd"))


for l in lib.get_test_benches():
   wave = ROOT.joinpath("test", "wave", f"{l.name}.tcl")
   l.set_sim_option("ghdl.gtkwave_script.gui", str(wave) if wave.is_file() else str(ROOT / "gtkwave.tcl"))

vu.main()
