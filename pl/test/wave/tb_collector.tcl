#python ../run.py --gtkwave-fmt vcd --gui lib.tb_collector.gtkw

set nfacts [ gtkwave::getNumFacs ]
puts "$nfacts"


for {set i 0} {$i < $nfacts} {incr i} {
   set name [gtkwave::getFacName $i]
   puts "$name"

   switch -glob -- $name {

      tb_collector.collector1.clk -
      tb_collector.collector1.counter_mic - 
      tb_collector.collector1.counter_row -
      tb_collector.collector1.data_in*    -
      tb_collector.collector1.data_valid -
      tb_collector.collector1.rd_enable -
      tb_collector.collector1.reset -
      tb_collector.data_in*    -
      tb_collector.data_test*    -

      tb_tb.a* {
         gtkwave::addSignalsFromList "$name"
      }
   }
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full

