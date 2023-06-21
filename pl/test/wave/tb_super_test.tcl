set nfacts [ gtkwave::getNumFacs ]
puts "$nfacts"


for {set i 2} {$i < $nfacts} {incr i} {
   set name [gtkwave::getFacName $i]
   puts "$name"

   switch -glob -- $name {
      tb_super_test.sck_clk -
      tb_super_test.clk -
      tb_super_test.ws - 
      tb_super_test.bit_stream_v* -
      tb_super_test.array_matrix_valid_out - 
      tb_super_test.chain_matrix_valid_o* -
      tb_super_test.mic_sample_valid_out - 
      tb_super_test.mic_sample_data_o* - 
      tb_super_test.tb_look* {
         gtkwave::addSignalsFromList "$name"
      }
   }
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full
