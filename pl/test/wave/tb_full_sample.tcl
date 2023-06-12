#python ../run.py --gtkwave-fmt vcd --gui lib.tb_full_sample.gtkw

set nfacts [ gtkwave::getNumFacs ]
puts "$nfacts"


for {set i 2} {$i < $nfacts} {incr i} {
   set name [gtkwave::getFacName $i]
   puts "$name"

   switch -glob -- $name { 
      tb_full_sample.clk -
      tb_full_sample.reset -
      tb_full_sample.array_matrix_valid_out -
      tb_full_sample.chain_matrix_valid_in* -
      tb_full_sample.sample_counter_array* -
      tb.tb.a* {
         gtkwave::addSignalsFromList "$name"
      }
   }
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full
