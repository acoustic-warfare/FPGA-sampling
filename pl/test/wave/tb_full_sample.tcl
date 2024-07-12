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
   tb_full_sample.clk -
   tb_full_sample.reset -
   tb_full_sample.array_matrix_valid_out -
   tb_full_sample.chain_matrix_valid_in -
}

foreach signal $signals {
   addSignal $signal
   #gtkwave::/Edit/Data_Format/Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full