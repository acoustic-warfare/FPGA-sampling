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
   tb_mux.clk
   tb_mux.reset

   tb_mux.mux_inst.rd_en
   tb_mux.mux_inst.rd_en_d

   tb_mux.mux_inst.counter

   tb_mux.data_out[31:0]
   tb_mux.rd_en_fifo
}

foreach signal $signals {
   addSignal $signal
   gtkwave::/Edit/Data_Format/Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full