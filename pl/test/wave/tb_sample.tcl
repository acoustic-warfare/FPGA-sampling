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
   tb_sample.sample_1.bit_stream -
   tb_sample.sample_1.sys_clk -
   tb_sample.sample_1.counter_samp -
   tb_sample.sample_1.counter_bit -
   tb_sample.sample_1.counter_mic -
   tb_sample.sample_1.reset -
   tb_sample.sample_1.state_1 -
   tb_sample.ws -
}

foreach signal $signals {
   addSignal $signal
   #gtkwave::/Edit/Data_Format/Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full