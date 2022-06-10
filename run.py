import sys
sys.path.append("/path/to/vunit_repo_root/")


from pathlib import Path
from vunit import VUnit

vu = VUnit.from_argv()   # Create Vuinit instance 

lib = vu.add_library("lib")   # create library lib

lib.add_source_files("*/*.vhd")


vu.main()
