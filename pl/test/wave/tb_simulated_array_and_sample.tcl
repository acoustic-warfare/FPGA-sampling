set nfacts [gtkwave::getNumFacs]
puts "$nfacts"

# Function to add a signal and handle errors if it doesn't exist
proc addSignal {signal} {
    set result [catch {gtkwave::addSignalsFromList "$signal"} error_message]
    if {$result != 0} {
        puts "Error adding signal $signal: $error_message"
    }
}

# List of signals to add
set signals {
    tb_simulated_array_and_sample.clk -
    tb_simulated_array_and_sample.sck_clk -
    tb_simulated_array_and_sample.reset -

    tb_simulated_array_and_sample.mic_sample_data_out -
    tb_simulated_array_and_sample.mic_sample_valid_out -

}

# Iterate through the list of signals and add them
foreach signal $signals {
    addSignal $signal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full