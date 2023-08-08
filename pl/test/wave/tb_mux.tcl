#python ../run.py --gtkwave-fmt vcd --gui lib.tb_full_sample.gtkw

set nfacts [ gtkwave::getNumFacs ]
puts "$nfacts"


for {set i 2} {$i < $nfacts} {incr i} {
   set name [gtkwave::getFacName $i]
   puts "$name"

   switch -glob -- $name { 
      tb_full_sample.clk -
      tb_full_sample.rd_en -
      tb_full_sample.rd_en_fifo -
      tb_full_sample.data* -
      tb_full_sample.fifo* -
      tb.tb.a* {
         gtkwave::addSignalsFromList "$name"
      }
   }
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full
