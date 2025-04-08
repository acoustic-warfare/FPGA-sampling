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
    tb_fft_controller.clk -
}

for {set i 0} {$i < 128} {incr i} {
    lappend signals "tb_fft_controller.fft_controller_inst.fft_data_in\[$i\] -"
}

foreach signal $signals {
    addSignal $signal
    gtkwave::/Edit/Data_Format/Signed_Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full