#
# Acustic Warfare environment setup
#
# NOTE: some locate patterns might be a bit lazy.
#       this might need some attention.
echo '
\033[34m⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾\033[5m⠀⠀⠀⣀⡀⠀⠀⠀⠀\033[0m
\033[34m⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿\033[5m⠀⠀⠀⠉⠛⢷⣄⠀⠀\033[0m
\033[34m⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⣠⣾⣿⣿⣿⣿\033[5m⠀⠀⠘⢶⣤⠀⠙⢷⡀\033[0m
\033[34m⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\033[5m⠀⠠⣄⠀⠙⣷⠀⠈⣷\033[0m
\033[34m⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\033[5m⠀⠀⢸⠆⠀⣿⠆⠀⣿\033[0m
\033[34m⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\033[5m⠀⠐⠋⠀⣠⡿⠀⢀⡿\033[0m
\033[34m⠀⠀⠀⠀⠀⠉⠉⠉⠉⠉⠙⢿⣿⣿⣿⣿\033[5m⠀⠀⢠⠾⠛⠀⣠⡾⠁\033[0m
\033[34m⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿\033[5m⠀⠀⠀⣀⣤⡾⠋⠀⠀\033[0m
\033[34m⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿\033[5m⠀⠀⠀⠉⠁⠀⠀⠀⠀\033[0m
'

#
# mlocate
#
# Check that mlocate is installed, as its required later.
# locate is used to allow for diffrences in install location
# between systems and are faster than find in the common case.
# NOTE: update db and check prune patterns if trouble shooting
if [ ! "$(command -v locate)" ]; then
    echo "\033[1;41mERROR: Please install 'mlocate'\033[0m"
    return 0
fi

#
# Python
#
# 'venv' setup and activation
VENV_NAME=".venv"
# TODO: trigger on changes to requirements.txt to stay up to date.
# NOTE: to slow to always run
if [ ! -d "$VENV_NAME" ]; then
    echo -e "Python environment setup"
    python3 -m venv $VENV_NAME
    $VENV_NAME/bin/python3 -m pip install setuptools wheel
    $VENV_NAME/bin/python3 -m pip install -r requirements.txt
fi
# TODO: Add explicit python min version and check
source $VENV_NAME/bin/activate
python3 --version

#
# Vivado
#
XILINX_PATH="/tools/Xilinx"
VIVADO_VERSION_17="2017.4"
[ $? -eq 0 ] && . "$XILINX_PATH/Vivado/$VIVADO_VERSION_17/settings64.sh" || echo -e "\033[1;33mWARNING: Could not locate Vivado $VIVADO_VERSION\033[0m"
echo "Vivado $VIVADO_VERSION_17"

VIVADO_VERSION_22="2022.1"
[ $? -eq 0 ] && . "$XILINX_PATH/Vivado/$VIVADO_VERSION_22/settings64.sh" || echo -e "\033[1;33mWARNING: Could not locate Vivado $VIVADO_VERSION\033[0m"
echo "Vivado $VIVADO_VERSION_22"

# TODO: set up simlibs and path to them
# NOTE: xsim will be needed for ip simulations if needed as most are verilog based

#
# GHDL
#
GHDL_PATH="$ "/usr/lib/ghdl""
GHDL_VERSION="$(ghdl --version | head -n1 | cut -d" " -f2)"
echo "GHDL $GHDL_VERSION"

#
# Useful aliases
#
alias run_test='zsh $(git rev-parse --show-toplevel)/pl/scripts/other/run_test.sh'
alias build='zsh $(git rev-parse --show-toplevel)/pl/scripts/other/build.sh'
alias build_simulated_array='vivado -notrace -mode batch -source $(git rev-parse --show-toplevel)/pl/scripts/build_simulated_array/build_only_simulated_array.tcl'
alias open_vivado_project='vivado -notrace -mode batch -source $(git rev-parse --show-toplevel)/pl/scripts/other/open_vivado_project.tcl'
alias open_sdk_project='vivado -notrace -mode batch -source $(git rev-parse --show-toplevel)/pl/scripts/other/open_sdk_project.tcl'
alias clean_vivado='sh pl/scripts/other/clean_vivado_files.sh'

echo -e '
Welcome to Acustic Warfare!
\033[4mCommands:\033[0m
\033[1m  run_test --help         \033[0m
\033[1m  build --help            \033[0m
\033[1m  clean_vivado --help     \033[0m
'

#
# Cleanup
#
unset GHDL_PATH GHDL_REQUIRED_VERSION GHDL_VERSION XILINX_PATH VENV_NAME VIVADO_VERSION
