#python ../run.py --gtkwave-fmt vcd --gui lib.tb_sample.gtkw

set nfacts [ gtkwave::getNumFacs ]
puts "$nfacts"


for {set i 2} {$i < $nfacts} {incr i} {
   set name [gtkwave::getFacName $i]
   puts "$name"

   switch -glob -- $name {
      tb_super_test.sample1.sys_clk -
      tb_super_test.sample1.bit_stream -
      tb_super_test.sample1.counter_samp -
      tb_super_test.sample1.counter_bit -
      tb_super_test.sample1.counter_mic -
      tb_super_test.sample1.rd_enable -
      tb_super_test.sample1.reg* -
      tb_super_test.sample1.reset -
      tb_super_test.sample1.sample_error -
      tb_super_test.sample1.state_1 -
      tb_super_test.sample1.ws -
      tb_super_test.sample1.sck_clk - 
      tb_super_test.sample_error -
      tb_super_test.ws -
      tb_tb.a* {
         gtkwave::addSignalsFromList "$name"
      }
   }
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full
