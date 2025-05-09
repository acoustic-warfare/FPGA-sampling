#!/bin/bash

files=(
    4k_fft_decode
    4k_fft_hann
    4k_fft_hamm
    4k_fft_rect
    4k_subband_decode
    4k_subband_decode
    drone_fft_decode
    drone_fft_standard
    drone_subband_decode
    drone_subband_standard
)

for file in "${files[@]}"; do
    echo "$file" | python3 python_scripts/analyze_simple.py
    #cp "./recorded_data/images/${file}.pdf" "$HOME/Projects/ExJobb_Rapport/images/results/"
done
