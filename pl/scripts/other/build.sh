BOLD=$(tput bold)
UNDERLINE=$(tput smul)
RESET_UNDERLINE=$(tput rmul)
RESET=$(tput sgr0)
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
   -h | --help) ;;
   # Add more flags here if needed
   *)
      # Ignore unrecognized flags, mabe print warning and help here
      ;;
   esac
done
# END FLAGS

if [ "$skip_vivado" = false ]; then
   rm $GIT_ROOT/pl/vivado_files -r
   vivado -notrace -mode batch -source $GIT_ROOT/pl/scripts/build_1_array/build_1_array.tcl
fi

if [ "$skip_sdk" = false ]; then
   rm $GIT_ROOT/pl/vivado_files/acoustic_warfare.sdk -r # remove folder first
   xsct $GIT_ROOT/pl/scripts/build_axi_full/launch_sdk.tcl
fi

cp "$BITSTREAM_PATH" "$DEST_DIR/bitstream"
cp "$ELF_PATH" "$DEST_DIR/ps.elf"