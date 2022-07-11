#python ../run.py --gtkwave-fmt vcd --gui lib.tb_full_sample.gtkw

set nfacts [ gtkwave::getNumFacs ]
puts "$nfacts"


for {set i 2} {$i < $nfacts} {incr i} {
   set name [gtkwave::getFacName $i]
   puts "$name"

   switch -glob -- $name {

      tb_full_sample.clk -
      tb_full_sample.counter_valid -
      tb_full_sample.data_test* -
      tb_full_sample.data_valid_v* -
      tb_full_sample.rd_counter -
      tb_full_sample.rd_enable -
      tb_full_sample.rd_enable_counter -
      tb_full_sample.reset -
      tb.tb.a* {
         gtkwave::addSignalsFromList "$name"
      }
   }
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full
