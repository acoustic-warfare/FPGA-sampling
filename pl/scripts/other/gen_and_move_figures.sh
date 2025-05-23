#!/bin/bash

files=(
    4k_subband
    4k_subband_decode
    4k_fft
    4k_fft_decode

    drone_subband
    drone_subband_decode
    drone_fft
    drone_fft_decode

    moving_drone_subband
    moving_drone_subband_decode
    moving_drone_fft
    moving_drone_fft_decode
)

for file in "${files[@]}"; do
    echo "$file" | python3 python_scripts/analyze_simple.py
    cp "./recorded_data/v21/images/${file}.pdf" "$HOME/Projects/ExJobb_Rapport/images/results/"
done
