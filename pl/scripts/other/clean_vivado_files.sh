#!/bin/sh

# FONTS
BOLD=$(tput bold)
UNDERLINE=$(tput smul)
RESET_UNDERLINE=$(tput rmul)
RESET=$(tput sgr0)

# FLAGS
rm_vivado_dir=false
for arg in "$@"; do
    case $arg in
    --rm_vivado_dir)
        rm_vivado_dir=true
        ;;
    -h | --help)
        echo "Usage: cleanup.sh [--rm_vivado_dir]"
        echo "  --rm_vivado_dir   Removes Vivado directory"
        exit 0
        ;;
    *)
        printf "%b\n" "${BOLD}${RED}Unknown option: $arg${RESET}"
        echo "Use --help or -h for usage instructions."
        exit 1
        ;;
    esac
done

## simple script to remove vivado files

if [ "$rm_vivado_dir" = true ]; then
    rm -r pl/vivado_files
fi

rm vivado.jou
rm vivado.log
rm vivado_pid*.str
rm vivado_*.log
rm vivado_*.jou
rm hs_err_pid*.log
rm vivado_*.zip
rm -r .Xil
