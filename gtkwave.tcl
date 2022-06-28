#python run.py "TEST_NAME" --gtkwave-fmt vcd --gtkwave-args=-Sgkwave.tcl --gui

##set nfacts [ gtkwave::getNumFacs ]

##for {set i 0} {$i < $nfacts} {incr i} {
##    set name [gtkwave::getFacName $i]

##    gtkwave::addSignalsFromList $name

    # Analog Waveforms
    # switch -glob -- $name {
    #     *cnt*    -
    #     tb_tb.a* {
    #         gtkwave::/Edit/Data_Format/Signed_Decimal
    #         gtkwave::/Edit/Data_Format/Analog/Step
    #         gtkwave::/Edit/Insert_Analog_Height_Extension
    #         gtkwave::/Edit/Insert_Analog_Height_Extension
    #     }
    # } 
##}

##gtkwave::/Edit/UnHighlight_All
##gtkwave::/Time/Zoom/Zoom_Full


set nfacs [ gtkwave::getNumFacs ]
set all_facs [list]
#for {set i 2} {$i < $nfacs } {incr i} {
#    set facname [ gtkwave::getFacName $i ]
#    lappend all_facs "$facname"
#}
#set num_added [ gtkwave::addSignalsFromList $all_facs ]
#puts "num signals added: $num_added"

# zoom full
gtkwave::/Time/Zoom/Zoom_Full

# Print (save as .pdf)
#set dumpname [ gtkwave::getDumpFileName ]
#gtkwave::/File/Print_To_File PDF {Letter (8.5" x 11")} Minimal $dumpname.pdf

