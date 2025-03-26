# make fullscreen (executes standard bash comand)
exec wmctrl -r GTKWave -b add,maximized_vert,maximized_horz &

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
    tb_simulated_array.clk -
    tb_simulated_array.simulated_array_inst.ws_edge -
    tb_simulated_array.simulated_array_inst.simulated_array_controller_inst.bit_counter -
    tb_simulated_array.simulated_array_inst.simulated_array_controller_inst.mic_counter -
    tb_simulated_array.simulated_array_inst.simulated_array_controller_inst.rd_data -
    tb_simulated_array.simulated_array_inst.simulated_array_controller_inst.bit_stream -



}

foreach signal $signals {
    addSignal $signal
    #gtkwave::/Edit/Data_Format/Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full