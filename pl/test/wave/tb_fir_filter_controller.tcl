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
    tb_fir_filter_controller.clk -
    tb_fir_filter_controller.reset -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_counter -
    tb_fir_filter_controller.fir_filter_controller_inst.state_1 -

    tb_fir_filter_controller.matrix_in_valid -
    tb_fir_filter_controller.matrix_out_valid -

    tb_fir_filter_controller.TB_matrix_in_0 -
    tb_fir_filter_controller.TB_matrix_in_1 -
    tb_fir_filter_controller.TB_matrix_in_2 -
    tb_fir_filter_controller.TB_matrix_in_3 -
    tb_fir_filter_controller.TB_matrix_in_4 -
    tb_fir_filter_controller.TB_matrix_in_5 -
    tb_fir_filter_controller.TB_matrix_in_6 -
    tb_fir_filter_controller.TB_matrix_in_7 -
    tb_fir_filter_controller.TB_matrix_in_8 -
    tb_fir_filter_controller.TB_matrix_in_9 -

    tb_fir_filter_controller.TB_matrix_out_0 -
    tb_fir_filter_controller.TB_matrix_out_1 -
    tb_fir_filter_controller.TB_matrix_out_2 -
    tb_fir_filter_controller.TB_matrix_out_3 -
    tb_fir_filter_controller.TB_matrix_out_4 -
    tb_fir_filter_controller.TB_matrix_out_5 -
    tb_fir_filter_controller.TB_matrix_out_6 -
    tb_fir_filter_controller.TB_matrix_out_7 -
    tb_fir_filter_controller.TB_matrix_out_8 -
    tb_fir_filter_controller.TB_matrix_out_9 -

}

# Iterate through the list of signals and add them
foreach signal $signals {
    addSignal $signal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full