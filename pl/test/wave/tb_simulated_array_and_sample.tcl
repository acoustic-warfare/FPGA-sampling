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
    tb_simulated_array_and_sample.clk -
    tb_simulated_array_and_sample.ws -
    tb_simulated_array_and_sample.sample_clk_inst.mic_sample_data_out -
    tb_simulated_array_and_sample.sample_clk_inst.mic_sample_valid_out -
    tb_simulated_array_and_sample.simulated_array_inst.simulated_array_controller_inst.addres_counter -

    tb_simulated_array_and_sample.tb_chain_matrix_data_0 -
    tb_simulated_array_and_sample.tb_chain_matrix_data_1 -
    tb_simulated_array_and_sample.tb_chain_matrix_data_2 -
    tb_simulated_array_and_sample.tb_chain_matrix_data_3 -
    tb_simulated_array_and_sample.tb_chain_matrix_data_4 -
    tb_simulated_array_and_sample.tb_chain_matrix_data_5 -
    tb_simulated_array_and_sample.tb_chain_matrix_data_6 -
    tb_simulated_array_and_sample.tb_chain_matrix_data_7 -
    tb_simulated_array_and_sample.tb_chain_matrix_data_8 -
    tb_simulated_array_and_sample.tb_chain_matrix_data_9 -
    tb_simulated_array_and_sample.tb_chain_matrix_data_10 -
    tb_simulated_array_and_sample.tb_chain_matrix_data_11 -
    tb_simulated_array_and_sample.tb_chain_matrix_data_12 -
    tb_simulated_array_and_sample.tb_chain_matrix_data_13 -
    tb_simulated_array_and_sample.tb_chain_matrix_data_14 -
    tb_simulated_array_and_sample.tb_chain_matrix_data_15 -

}

foreach signal $signals {
    addSignal $signal
    gtkwave::/Edit/Data_Format/Decimal
}

# zoom full
gtkwave::/View/Fullscreen
gtkwave::/Time/Zoom/Zoom_Full