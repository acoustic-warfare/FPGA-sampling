#python ../run.py --gtkwave-fmt vcd --gui lib.tb_sample.tb_sample_1

set nfacts [ gtkwave::getNumFacs ]
puts "$nfacts"


for {set i 2} {$i < $nfacts} {incr i} {
    set name [gtkwave::getFacName $i]
    puts "$name"

    switch -glob -- $name {
         *cnt*    - 
         *clk*    -
         tb_tb.a* {
            puts "$name"
            gtkwave::addSignalsFromList "$name"
         }
     } 
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full
