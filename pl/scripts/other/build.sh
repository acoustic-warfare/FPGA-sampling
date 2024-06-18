BOLD=$(tput bold)
UNDERLINE=$(tput smul)
RESET_UNDERLINE=$(tput rmul)
RESET=$(tput sgr0)
GREEN='\033[0;32m' # Green color
RED='\033[0;31m'   # Red color
NC='\033[0m'       # No color (reset)
## END FONTS

# PATHS
# Get root path of Git repository
GIT_ROOT=$(git rev-parse --show-toplevel)

# Define relative paths within the repository
BITSTREAM_PATH="$GIT_ROOT/pl/vivado_files/acoustic_warfare.runs/impl_1/aw_top.bit"
ELF_PATH="$GIT_ROOT/pl/vivado_files/acoustic_warfare.sdk/aw_udp_ps/Debug/aw_udp_ps.elf"

# Destination tftp directory
DEST_DIR="$GIT_ROOT/../beamforming-lk/boot/tftp"
# END PATHS

# FLAGS
skip_vivado=false
skip_sdk=false
for arg in "$@"; do
   case $arg in
   --skip_vivado)
      skip_vivado=true
      ;;
   --skip_sdk)
      skip_sdk=true
      ;;
   -h | --help)
      echo "Usage: ./script.sh [--skip_vivado] [--skip_sdk]"
      echo "  --skip_vivado   Skip Vivado tasks"
      echo "  --skip_sdk      Skip SDK tasks"
      exit 0
      ;;
   *)
      printf "%b\n" "${BOLD}${RED}Unknown option: $arg${RESET}"
      echo "Use --help for usage instructions."
      exit 1
      ;;
   esac
done
# END FLAGS

if [ "$skip_vivado" = false ]; then
   source /tools/Xilinx/Vivado/2022.1/settings64.sh
   if [ -d "$GIT_ROOT/pl/vivado_files" ]; then
      rm -r "$GIT_ROOT/pl/vivado_files"
   fi
   vivado -notrace -mode batch -source $GIT_ROOT/pl/scripts/build_axi_full/build_axi_full.tcl
fi

if [ "$skip_sdk" = false ]; then
   source /tools/Xilinx/SDK/2017.4/settings64.sh
   if [ -d "$GIT_ROOT/pl/vivado_files/acoustic_warfare.sdk" ]; then
      rm -r "$GIT_ROOT/pl/vivado_files/acoustic_warfare.sdk" # remove folder if it exists
   fi   
   xsct $GIT_ROOT/pl/scripts/build_axi_full/launch_sdk.tcl
fi

printf "%b\n" "${BOLD}copying files...${RESET}"
cp "$BITSTREAM_PATH" "$DEST_DIR/bitstream"
cp "$ELF_PATH" "$DEST_DIR/ps.elf"

printf "%b\n" "${BOLD}${GREEN}done!${RESET}"
exit 0
