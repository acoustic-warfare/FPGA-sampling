# 
# Acustic Warfare environment setup
#
# NOTE: some locate patterns might be a bit lazy.
#       this might need some attention.
echo '
\033[30m⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾\033[5m⠀⠀⠀⣀⡀⠀⠀⠀⠀\033[0m
\033[30m⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿\033[5m⠀⠀⠀⠉⠛⢷⣄⠀⠀\033[0m
\033[30m⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⣠⣾⣿⣿⣿⣿\033[5m⠀⠀⠘⢶⣤⠀⠙⢷⡀\033[0m
\033[30m⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\033[5m⠀⠠⣄⠀⠙⣷⠀⠈⣷\033[0m
\033[30m⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\033[5m⠀⠀⢸⠆⠀⣿⠆⠀⣿\033[0m
\033[30m⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\033[5m⠀⠐⠋⠀⣠⡿⠀⢀⡿\033[0m
\033[30m⠀⠀⠀⠀⠀⠉⠉⠉⠉⠉⠙⢿⣿⣿⣿⣿\033[5m⠀⠀⢠⠾⠛⠀⣠⡾⠁\033[0m
\033[30m⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿\033[5m⠀⠀⠀⣀⣤⡾⠋⠀⠀\033[0m
\033[30m⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿\033[5m⠀⠀⠀⠉⠁⠀⠀⠀⠀\033[0m
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
VENV_NAME="venv"
# TODO: trigger on changes to requirements.txt to stay up to date.
# NOTE: to slow to always run
if [ ! -d "$VENV_NAME" ]; then
    echo -e "Python environemnt setup"
    python3 -m venv $VENV_NAME
    $VENV_NAME/bin/python -m pip install setuptools wheel
    $VENV_NAME/bin/python -m pip install -r requirements.txt
fi
# TODO: Add explicit python min version and check
. $VENV_NAME/bin/activate    
python --version


#
# Vivado
#
VIVADO_VERSION="2017.4"
XILINX_PATH="$(locate -n1 "/Xilinx/Vivado/$VIVADO_VERSION" )"
[ $? -eq 0 ] && . "$XILINX_PATH/settings64.sh" || echo -e "\033[1;33mWARNING: Could not locate Vivado $VIVADO_VERSION\033[0m" 
echo "Vivado $VIVADO_VERSION"

# TODO: set up simlibs and path to them
# NOTE: xsim will be needed for ip simulations if needed as most are verilog based


#
# GHDL
#
# TODO: Handle system with multiple ghdl versions
# TODO: Check GHDL version >= min version
# TODO: Check if build with 2008 libraries
GHDL_REQUIRED_VERSION="2.0.0"
GHDL_PATH="$(dirname $(locate -n1 bin/ghdl) 2> /dev/null )"
if [ -e "$GHDL_PATH" ]; then 
    export PATH=$GHDL_PATH:$PATH     
    GHDL_VERSION="$(ghdl --version | head -n1 | cut -d" " -f2)"
    # Use python to resolve semantic vesrsioning 
    python -c "from pip._vendor.packaging.version import parse; raise SystemExit(not parse(\"$GHDL_REQUIRED_VERSION\") <= parse(\"$GHDL_VERSION\"))"
    [ $? -eq 0 ] || echo -e "\033[1;41mERROR: GHDL version '$GHDL_VERSION' less then required '$GHDL_REQUIRED_VERSION'\033[0m"
    echo "GHDL   $GHDL_VERSION"   
else
    echo -e "\033[1;33mWARNING: Could not locate GHDL installation\033[0m"
fi

#
# Useful aliases
#
alias clean="git clean -xdie $VENV_NAME"
alias vunit='python $(git rev-parse --show-toplevel)/pl/run.py --gtkwave-fmt vcd'
alias gtkwave='python $(git rev-parse --show-toplevel)/pl/run.py --gtkwave-fmt vcd --gui'
alias build='vivado -notrace -mode batch -source $(git rev-parse --show-toplevel)/pl/scripts/gen_all.tcl'

echo -e '
Welcome to Acustic Warfare!
   To run a test bench for a HDL-file write: vuinit "*HDL_file_name*"
   To run a test in a waveform viewer write: gtkwave "*HDL_file_name.wave"
   To create and lanch the Vivado project write: gen_all
\033[4mCommands:\033[0m
\033[1m    vunit\033[0m    Run PL tests ("vunit --help" for usage)
\033[1m    build\033[0m    Build PL ("build -help" for usage)
\033[1m    clean\033[0m    Clean project (interactive) (excluding venv)
'

#
# Cleanup
#
unset GHDL_PATH GHDL_REQUIRED_VERSION GHDL_VERSION XILINX_PATH VENV_NAME VIVADO_VERSION