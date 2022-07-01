#python ../run.py --gtkwave-fmt vcd --gui lib.tb_clk_gen.gtkw

set nfacts [ gtkwave::getNumFacs ]
puts "$nfacts"


for {set i 2} {$i < $nfacts} {incr i} {
   set name [gtkwave::getFacName $i]
   puts "$name"

   switch -glob -- $name {

      tb_clk_gen.reset -
      tb_clk_gen.sck_clk -
      tb_clk_gen.sck_count -
      tb_clk_gen.ws_count -
      tb_clk_gen.ws_pulse -
      tb_tb.a* {
         gtkwave::addSignalsFromList "$name"
      }
   }
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full
