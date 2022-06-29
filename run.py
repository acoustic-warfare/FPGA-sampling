from pathlib import Path
from vunit import VUnit


# NOTE: Path to directory containing this file
ROOT = Path(__file__).parent

vu = VUnit.from_argv()

lib = vu.add_library("lib")
lib.add_source_files(ROOT.glob("*/*.vhd"))

for l in lib.get_test_benches():
   wave = ROOT.joinpath("test", "wave", f"{l.name}.tcl")
   l.set_sim_option("ghdl.gtkwave_script.gui", str(wave) if wave.is_file() else str(ROOT / "gtkwave.tcl"))

vu.main()
