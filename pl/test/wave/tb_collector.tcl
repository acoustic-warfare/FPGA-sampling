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
   tb_collector.clk -
   tb_collector.reset -
   tb_collector.collector_inst.counter_mic -
   tb_collector.data_test1 -
   tb_collector.data_test2 -
   tb_collector.data_test3 -
   tb_collector.data_test4 -

}

foreach signal $signals {
   addSignal $signal
   #gtkwave::/Edit/Data_Format/Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full