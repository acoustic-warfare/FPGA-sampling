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
   tb_decode_ema.clk
   tb_decode_ema.decode_ema_inst.down_sampled_valid
   tb_decode_ema.decode_ema_inst.subband_out
   tb_decode_ema.decode_ema_inst.decoded_valid
   tb_decode_ema.decode_ema_inst.ema_34.ema_max

}

foreach signal $signals {
   addSignal $signal
   gtkwave::/Edit/Data_Format/Decimal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full

