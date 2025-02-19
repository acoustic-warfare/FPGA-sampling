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
    tb_folded_fir_dsp.clk -
    tb_folded_fir_dsp.folded_fir_dsp_inst.data_0 -
    tb_folded_fir_dsp.folded_fir_dsp_inst.data_1 -
    tb_folded_fir_dsp.folded_fir_dsp_inst.pre_sum -
    tb_folded_fir_dsp.folded_fir_dsp_inst.pre_sum_d -
    tb_folded_fir_dsp.folded_fir_dsp_inst.coeff -
    tb_folded_fir_dsp.folded_fir_dsp_inst.mul -
    tb_folded_fir_dsp.folded_fir_dsp_inst.mul_d -
    tb_folded_fir_dsp.folded_fir_dsp_inst.data_sum -
    tb_folded_fir_dsp.folded_fir_dsp_inst.post_sum -
    tb_folded_fir_dsp.folded_fir_dsp_inst.post_sum_d -
    tb_folded_fir_dsp.folded_fir_dsp_inst.result -
}

foreach signal $signals {
    addSignal $signal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full