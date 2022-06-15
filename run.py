from pathlib import Path
from vunit import VUnit

# NOTE: Path to directory containing this file
ROOT = Path(__file__).parent

vu = VUnit.from_argv()

lib = vu.add_library("lib")
lib.add_source_files(ROOT.glob("*/*.vhd"))

vu.main()
