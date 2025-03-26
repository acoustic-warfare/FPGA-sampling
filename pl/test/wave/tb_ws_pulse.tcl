# make fullscreen (executes standard bash comand)
exec wmctrl -r GTKWave -b add,maximized_vert,maximized_horz &

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
   tb_ws_pulse.sck_clk -
   tb_ws_pulse.sck_counter -
   tb_ws_pulse.reset -
   tb_ws_pulse.ws -
   tb_ws_pulse.ws_counter -
}

foreach signal $signals {
   addSignal $signal
   #gtkwave::/Edit/Data_Format/Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full