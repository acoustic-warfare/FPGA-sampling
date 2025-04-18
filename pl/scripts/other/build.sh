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
BITSTREAM_PATH_SIM_ARRAY="$GIT_ROOT/pl/vivado_files/acoustic_warfare.runs/impl_1/simulated_array.bit"
ELF_PATH="$GIT_ROOT/pl/vivado_files/acoustic_warfare.sdk/aw_udp_ps/Debug/aw_udp_ps.elf"

# Destination tftp directory
DEST_DIR="$GIT_ROOT/../beamforming-lk/boot/tftp"
DOCKERFILE_DIR="$GIT_ROOT/../beamforming-lk/boot"
TFTP_DIR="$GIT_ROOT/../beamforming-lk/boot/tftp"
# END PATHS

# FLAGS
skip_vivado=false
skip_sdk=false
skip_docker=false
vivado_gui=false
sdk_gui=false
simulated_array=false

for arg in "$@"; do
   case $arg in
   --skip_vivado)
      skip_vivado=true
      ;;
   --skip_sdk)
      skip_sdk=true
      ;;
   --skip_docker)
      skip_docker=true
      ;;
   --vivado_gui)
      vivado_gui=true
      ;;
   --sdk_gui)
      sdk_gui=true
      ;;
   --simulated_array)
      simulated_array=true
      skip_sdk=true
      ;;
   -h | --help)
      echo "Usage: ./script.sh [--skip_vivado] [--skip_sdk]"
      echo "  --skip_vivado      Skip Vivado tasks"
      echo "  --skip_sdk         Skip SDK tasks"
      echo "  --skip_docker      Skip setting up Docker"
      echo "  --vivado_gui       Open Vivado gui"
      echo "  --sdk_gui          Open SDK gui"
      echo "  --simulated_array  Build standalone simulated array"
      exit 0
      ;;
   *)
      printf "%b\n" "${RED}Unknown option: $arg${RESET}"
      echo "Use --help or -h for usage instructions."
      exit 1
      ;;
   esac
done
# END FLAGS

if [ "$skip_vivado" = false ]; then
   source /tools/Xilinx/Vivado/2024.2/settings64.sh
   if [ -d "$GIT_ROOT/pl/vivado_files" ]; then
      rm -r "$GIT_ROOT/pl/vivado_files"
   fi

   if [ "$simulated_array" = true ]; then
      # build simulated array

      # run python_scrips/gen_array_data.py to generate data, edit in the script to customize the signal sent from the simulated array
      echo "${GREEN} Generating data using gen_array_data.py ${RESET}"
      #run program and save first print to (length)
      length=$({ python3 $GIT_ROOT/python_scripts/gen_array_data.py | tee /dev/tty; } | head -n 1)
      echo "Setting length of bram to length: $length"

      echo "${GREEN} Starting Vivado ${RESET}"
      vivado -notrace -mode batch -source $GIT_ROOT/pl/scripts/build_simulated_array/build_only_simulated_array.tcl -tclargs $length
      printf "%b\n" "${BOLD}copying bitstream...${RESET}"
      cp "$BITSTREAM_PATH_SIM_ARRAY" "$DEST_DIR/bitstream"
   else
      # normal build
      echo "${GREEN} Starting Vivado ${RESET}"
      vivado -notrace -mode batch -source $GIT_ROOT/pl/scripts/build_axi_full/build_axi_full.tcl
      printf "%b\n" "${BOLD}copying bitstream...${RESET}"
      cp "$BITSTREAM_PATH" "$DEST_DIR/bitstream"
   fi
fi

if [ "$vivado_gui" = true ]; then
   vivado -notrace -mode batch -source $GIT_ROOT/pl/scripts/other/open_vivado_project.tcl
fi

if [ "$skip_sdk" = false ]; then
   source /tools/Xilinx/SDK/2017.4/settings64.sh
   if [ -d "$GIT_ROOT/pl/vivado_files/acoustic_warfare.sdk" ]; then
      rm -r "$GIT_ROOT/pl/vivado_files/acoustic_warfare.sdk" # remove folder if it exists
   fi
   xsct $GIT_ROOT/pl/scripts/build_axi_full/launch_sdk.tcl
   printf "%b\n" "${BOLD}copying ps.elf...${RESET}"
   cp "$ELF_PATH" "$DEST_DIR/ps.elf"
fi

if [ "$sdk_gui" = true ]; then
   source /tools/Xilinx/SDK/2017.4/settings64.sh
   WORKSPACE_PATH="pl/vivado_files/acoustic_warfare.sdk"
   xsdk -workspace $WORKSPACE_PATH &
fi

IMAGE_NAME="tftpd"
CONTAINER_NAME="tftp-server"

if [ "$skip_docker" = false ]; then
   # Check if the Docker image exists
   if [ -z "$(sudo docker images -q $IMAGE_NAME)" ]; then
      echo "Docker image $IMAGE_NAME does not exist. Building the image..."
      sudo docker build -t $IMAGE_NAME -f $DOCKERFILE_DIR/Dockerfile .
   else
      echo "Docker image $IMAGE_NAME already exists. Skipping build."
   fi

   # Check if the Docker container is running
   if sudo docker ps --filter "name=$CONTAINER_NAME" --format "{{.Names}}" | grep -w $CONTAINER_NAME >/dev/null; then
      echo "Docker container $CONTAINER_NAME is already running."
   else
      echo "Docker container $CONTAINER_NAME is not running. Starting the container..."
      sudo docker run -it -d --rm --network=host -v $TFTP_DIR:/var/lib/tftpboot --name $CONTAINER_NAME $IMAGE_NAME
   fi
fi

printf "%b\n" "${GREEN}done!${RESET}"
exit 0
