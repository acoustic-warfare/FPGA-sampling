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
   tb_ema.clk
   tb_ema.reset

}

foreach signal $signals {
   addSignal $signal
   gtkwave::/Edit/Data_Format/Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full