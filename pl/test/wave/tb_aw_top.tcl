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
   tb_aw_top.sys_clock -
   tb_aw_top.aw_top_inst.clk -
   tb_aw_top.reset -
   tb_aw_top.aw_top_inst.ws -
   tb_aw_top.aw_top_inst.sample_gen_0(3).sample_c.bit_stream -
   tb_aw_top.aw_top_inst.sample_gen_0(3).sample_c.mic_sample_data_out -
   tb_aw_top.aw_top_inst.sample_gen_0(3).sample_c.mic_sample_valid_out -

}

foreach signal $signals {
   addSignal $signal
   gtkwave::/Edit/Data_Format/Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full