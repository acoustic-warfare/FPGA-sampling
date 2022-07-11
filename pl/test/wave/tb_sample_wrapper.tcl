#python ../run.py --gtkwave-fmt vcd --gui lib.tb_sample_wrapper.gktw

set nfacts [ gtkwave::getNumFacs ]
puts "$nfacts"


for {set i 2} {$i < $nfacts} {incr i} {
   set name [gtkwave::getFacName $i]
   puts "$name"

   switch -glob -- $name {

      tb_sample_wrapper.clk -
      tb_sample_wrapper.array_matrix_valid_out -
      tb_sample_wrapper.matrix_row_* -
      tb.tb.a* {
         gtkwave::addSignalsFromList "$name"
      }
   }
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full
