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
    tb_transposed_fir.clk -
    tb_transposed_fir.transposed_fir_inst.data_in -
    tb_transposed_fir.transposed_fir_inst.data_out -

}

foreach signal $signals {
    addSignal $signal
    gtkwave::/Edit/Data_Format/Signed_Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full