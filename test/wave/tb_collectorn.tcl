#python ../run.py --gtkwave-fmt vcd --gui lib.tb_collectorn.tb_collectorn_1

set nfacts [ gtkwave::getNumFacs ]
puts "$nfacts"


for {set i 0} {$i < $nfacts} {incr i} {
   set name [gtkwave::getFacName $i]
   puts "$name"

   switch -glob -- $name {

      tb_collectorn.collectorn1.clk
      tb_collectorn.collectorn1.counter_mic
      tb_collectorn.collectorn1.counter_row
      tb_collectorn.collectorn1.data_in*    -
      tb_collectorn.collectorn1.data_valid
      tb_collectorn.collectorn1.rd_enable
      tb_collectorn.collectorn1.reset
      tb_collectorn.data_in*    -
      tb_collectorn.data_test*    -
      tb_tb.a* {
         puts "$name"
         gtkwave::addSignalsFromList "$name"
      }
   }
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full

