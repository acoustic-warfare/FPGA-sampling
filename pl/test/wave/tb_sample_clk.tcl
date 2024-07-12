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
   tb_sample_clk.sample_clk1.bit_stream -
   tb_sample_clk.sample_clk1.clk -
   tb_sample_clk.sample_clk1.counter_1s -
   tb_sample_clk.sample_clk1.counter_samp -
   tb_sample_clk.sample_clk1.counter_bit -
   tb_sample_clk.sample_clk1.counter_mic -
   tb_sample_clk.sample_clk1.rd_enable -
   tb_sample_clk.sample_clk1.reg -
   tb_sample_clk.sample_clk1.reset -
   tb_sample_clk.sample_clk1.state -
   tb_sample_clk.ws -
}

foreach signal $signals {
   addSignal $signal
   #gtkwave::/Edit/Data_Format/Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full