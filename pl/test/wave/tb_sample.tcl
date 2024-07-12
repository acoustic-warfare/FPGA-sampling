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
   tb_sample.sck_clk -
   tb_sample.ws -
   tb_sample.reset -
   tb_sample.sample_inst.bit_stream -
   tb_sample.sample_inst.counter_bit -
   tb_sample.sample_inst.counter_mic -
   tb_sample.sample_inst.state_1 -
}

foreach signal $signals {
   addSignal $signal
   gtkwave::/Edit/Data_Format/Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full