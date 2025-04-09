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
    tb_fft.clk -
    tb_fft.fft_inst.result_reg_0_r[0] -
    tb_fft.fft_inst.result_reg_0_i[0] -

}

for {set i 0} {$i < 128} {incr i} {
    #lappend signals "tb_fft.clk -"
    #lappend signals "tb_fft.fft_inst.result_reg_0_r\[$i\] -"
    #lappend signals "tb_fft.fft_inst.result_reg_0_i\[$i\] -"
}

foreach signal $signals {
    addSignal $signal
    gtkwave::/Edit/Data_Format/Signed_Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full