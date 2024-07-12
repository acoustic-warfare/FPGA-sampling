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
   tb_simulated_array.simulated_array_inst.clk -
   tb_simulated_array.simulated_array_inst.sck_clk -
   tb_simulated_array.simulated_array_inst.ws -
   tb_simulated_array.simulated_array_inst.bit_stream_in -
   tb_simulated_array.simulated_array_inst.bit_stream_out -
}

foreach signal $signals {
   addSignal $signal
   #gtkwave::/Edit/Data_Format/Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full