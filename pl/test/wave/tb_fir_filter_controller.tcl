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


    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.data_in -

    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_in_0 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_in_1 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_in_2 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_in_3 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_in_4 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_in_5 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_in_6 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_in_7 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_in_8 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_in_9 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_out_0 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_out_1 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_out_2 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_out_3 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_out_4 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_out_5 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_out_6 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_out_7 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_out_8 -
    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.TB_mem_out_9 -

    tb_fir_filter_controller.fir_filter_controller_inst.fir_filter_inst.data_out -



}

# Iterate through the list of signals and add them
foreach signal $signals {
    addSignal $signal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full