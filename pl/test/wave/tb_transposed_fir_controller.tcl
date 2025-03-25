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
    tb_transposed_fir_controller.clk -
    tb_transposed_fir_controller.transposed_fir_controller_inst.mic_counter -
    tb_transposed_fir_controller.transposed_fir_controller_inst.band_counter -

}

foreach signal $signals {
    addSignal $signal
    gtkwave::/Edit/Data_Format/Signed_Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full