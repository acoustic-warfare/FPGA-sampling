BOLD=$(tput bold)
UNDERLINE=$(tput smul)
RESET_UNDERLINE=$(tput rmul)
RESET=$(tput sgr0)

## simple script to remove vivado files

# TODO: make this better and add some nice prints and flags


rm_vivado_dir = false

# for flags
for arg in "$@"; do
    case $arg in
    --rm_vivado_dir)
        rm_vivado_dir=true
        ;;
    -h | --help)
        ;;
    # Add more flags here if needed
    *)
        # Ignore unrecognized flags, mabe print warning and help here
        ;;
    esac
done

if [ "$rm_txt" = true ]; then
   rm pl/vivado_files -r
fi

rm vivado.jou
rm vivado.log
rm vivado_pid*.str
rm vivado_*.log
rm vivado_*.jou
rm hs_err_pid*.log
rm vivado_*.zip