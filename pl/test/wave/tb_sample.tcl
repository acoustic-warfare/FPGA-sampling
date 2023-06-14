#python ../run.py --gtkwave-fmt vcd --gui lib.tb_sample.gtkw

set nfacts [ gtkwave::getNumFacs ]
puts "$nfacts"


for {set i 2} {$i < $nfacts} {incr i} {
   set name [gtkwave::getFacName $i]
   puts "$name"

   switch -glob -- $name {
      tb_sample.sample1.bit_stream -
      tb_sample.sample1.clk -
      tb_sample.sample1.counter_1s -
      tb_sample.sample1.counter_samp -
      tb_sample.sample1.counter_bit -
      tb_sample.sample1.counter_mic -
      tb_sample.sample1.rd_enable -
      tb_sample.sample1.reg* -
      tb_sample.sample1.reset -
      tb_sample.sample1.sample_error -
      tb_sample.sample1.state_1 -
      tb_sample.sample1.ws -
      tb_sample.sample1.sck_clk - 
      tb_sample.sample_error -
      tb_sample.ws -
      tb_tb.a* {
         gtkwave::addSignalsFromList "$name"
      }
   }
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full
