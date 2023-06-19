#python ../run.py --gtkwave-fmt vcd --gui lib.tb_sample.gtkw

set nfacts [ gtkwave::getNumFacs ]
puts "$nfacts"


for {set i 2} {$i < $nfacts} {incr i} {
   set name [gtkwave::getFacName $i]
   puts "$name"

   switch -glob -- $name {
      tb_sample_clk.sample_clk1.bit_stream -
      tb_sample_clk.sample_clk1.clk -
      tb_sample_clk.sample_clk1.counter_1s -
      tb_sample_clk.sample_clk1.counter_samp -
      tb_sample_clk.sample_clk1.counter_bit -
      tb_sample_clk.sample_clk1.counter_mic -
      tb_sample_clk.sample_clk1.rd_enable -
      tb_sample_clk.sample_clk1.reg* -
      tb_sample_clk.sample_clk1.reset -
      tb_sample_clk.sample_clk1.sample_error -
      tb_sample_clk.sample_clk1.state -
      tb_sample_clk.sample_clk1.ws -
      tb_sample_clk.sample_error -
      tb_sample_clk.ws -
      tb_tb.a* {
         gtkwave::addSignalsFromList "$name"
      }
   }
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full
