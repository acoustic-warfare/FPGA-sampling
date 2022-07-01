#python ../run.py --gtkwave-fmt vcd --gui lib.tb_sample_block.tb_sample_block_1

set nfacts [ gtkwave::getNumFacs ]
puts "$nfacts"


for {set i 2} {$i < $nfacts} {incr i} {
   set name [gtkwave::getFacName $i]
   puts "$name"

   switch -glob -- $name {

      tb_sample_block.bit_stream_v -
      tb_sample_block.clk -
      tb_sample_block.data_valid -
      tb_sample_block.matrix_row_* -
      tb.tb.a* {
         gtkwave::addSignalsFromList "$name"
      }
   }
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full
