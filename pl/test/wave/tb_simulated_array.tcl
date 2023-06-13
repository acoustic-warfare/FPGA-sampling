#python ../run.py --gtkwave-fmt vcd --gui lib.tb_sample.gtkw

set nfacts [ gtkwave::getNumFacs ]
puts "$nfacts"


for {set i 2} {$i < $nfacts} {incr i} {
   set name [gtkwave::getFacName $i]
   puts "$name"

   switch -glob -- $name {
      tb_simulated_array.simulated_array1.bit_stream - 
      tb_simulated_array.simulated_array1.ws0 - 
      tb_simulated_array.simulated_array1.sck_clk0 - 

      tb_tb.a* {
         gtkwave::addSignalsFromList "$name"
      }
   }
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full
