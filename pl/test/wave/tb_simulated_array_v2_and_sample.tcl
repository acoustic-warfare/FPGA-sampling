set nfacts [gtkwave::getNumFacs]
puts "$nfacts"

proc addSignal {signal} {
    set result [catch {gtkwave::addSignalsFromList "$signal"} error_message]
    if {$result != 0} {
        puts "Error adding signal $signal: $error_message"
    }
}

# List of signals to add
set signals {
    tb_simulated_array_v2_and_sample.clk -
    tb_simulated_array_v2_and_sample.ws -
    #tb_simulated_array_v2_and_sample.simulated_array_v2.simulated_array_controller.bit_counter -
    #tb_simulated_array_v2_and_sample.simulated_array_v2.simulated_array_controller.mic_counter -
    #tb_simulated_array_v2_and_sample.simulated_array_v2.simulated_array_controller.rd_data -
    #tb_simulated_array_v2_and_sample.simulated_array_v2.simulated_array_controller.bit_stream -
    tb_simulated_array_v2_and_sample.sample_clk_inst.mic_sample_data_out -
    tb_simulated_array_v2_and_sample.sample_clk_inst.mic_sample_valid_out -



}

foreach signal $signals {
    addSignal $signal
    gtkwave::/Edit/Data_Format/Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full