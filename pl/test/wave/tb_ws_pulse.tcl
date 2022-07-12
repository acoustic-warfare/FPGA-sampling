#python ../run.py --gtkwave-fmt vcd --gui lib.tb_ws_pulse.gtkw

set nfacts [ gtkwave::getNumFacs ]
puts "$nfacts"


for {set i 2} {$i < $nfacts} {incr i} {
   set name [gtkwave::getFacName $i]
   puts "$name"

   switch -glob -- $name {

      tb_ws_pulse.reset -
      tb_ws_pulse.sck_clk -
      tb_ws_pulse.sck_count -
      tb_ws_pulse.ws_count -
      tb_ws_pulse.ws* -
      tb_tb.a* {
         gtkwave::addSignalsFromList "$name"
      }
   }
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full
