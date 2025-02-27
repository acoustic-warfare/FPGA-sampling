#!/bin/sh

# FONTS
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
# END PATHS

# FLAGS
wave_test=false
wave_full_test=false
auto_test=false
test_name=""
for arg in "$@"; do
    case $arg in
    --wave)
        wave_test=true
        ;;
    --wave_full)
        wave_full_test=true
        ;;
    --auto)
        auto_test=true
        ;;
    -h | --help)
        echo "Usage: run_test [--wave <test_name>] [--auto <test_name>]"
        echo "  --wave <test_name>   Run wave test with specified test name"
        echo "  --wave_full <test_name>   Same as wave exept it uses gtk format that allows matrixes in gtkwave but takes alot longer time"
        echo "  --auto <test_name>   Run auto test with specified test name"
        exit 0
        ;;
    *)
        if [ "$wave_test" = true ] && [ -z "$test_name" ]; then
            test_name=$arg
        elif [ "$wave_full_test" = true ] && [ -z "$test_name" ]; then
            test_name=$arg
        elif [ "$auto_test" = true ] && [ -z "$test_name" ]; then
            test_name=$arg
        else
            printf "%b\n" "${BOLD}${RED}Unknown option: $arg${RESET}"
            echo "Use --help or -h for usage instructions."
            exit 1
        fi
        ;;
    esac
done
# END FLAGS

# Check if no arguments were provided
if [ "$wave_test" = false ] && [ "$wave_full_test" = false ] && [ "$auto_test" = false ]; then
    printf "%b\n" "${BOLD}${RED}Missing argument: --auto or --wave${RESET}"
    echo "Use --help or -h for usage instructions."
    exit 1
fi

if [ "$wave_test" = true ]; then
    if [ -z "$test_name" ]; then
        printf "%b\n" "${BOLD}${RED}Missing test bench name for --wave${RESET}"
        echo "Use --help or -h for usage instructions."
        exit 1
    else
        printf "%b\n" "${BOLD}Running wave test${RESET}"
        python3 "$GIT_ROOT/pl/run.py" --gtkwave-fmt vcd --gui "*$test_name.wave*" -p 0
    fi
fi

if [ "$wave_full_test" = true ]; then
    if [ -z "$test_name" ]; then
        printf "%b\n" "${BOLD}${RED}Missing test bench name for --wave${RESET}"
        echo "Use --help or -h for usage instructions."
        exit 1
    else
        printf "%b\n" "${BOLD}Running full wave test${RESET}"
        python3 "$GIT_ROOT/pl/run.py" --gui "*$test_name.wave*" -p 0
    fi
fi

if [ "$auto_test" = true ]; then
    if [ -z "$test_name" ]; then
        printf "%b\n" "${BOLD}${RED}Missing test bench name for --auto${RESET}"
        echo "Use --help or -h for usage instructions."
        exit 1
    else
        printf "%b\n" "${BOLD}Running auto test${RESET}"
        python3 "$GIT_ROOT/pl/run.py" -v "*$test_name.auto*" -p 0
    fi
fi

printf "%b\n" "${BOLD}${GREEN}done!${RESET}"
exit 0
