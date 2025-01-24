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
    tb_simulated_array_controller.clk -
    tb_simulated_array_controller.sck_edge -
    tb_simulated_array_controller.ws_edge -
    tb_simulated_array_controller.simulated_array_controller.bit_counter -
    tb_simulated_array_controller.simulated_array_controller.mic_counter -
    tb_simulated_array_controller.simulated_array_controller.rd_data -
    tb_simulated_array_controller.simulated_array_controller.bit_stream -



}

foreach signal $signals {
    addSignal $signal
    #gtkwave::/Edit/Data_Format/Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full