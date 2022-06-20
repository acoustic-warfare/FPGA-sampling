#python run.py "*1" --gtkwave-fmt vcd --gtkwave-args=-Stest.tcl --gui
#python run.py "TEST_NAME" --gtkwave-fmt vcd --gtkwave-args=-Stest.tcl --gui
'
set nfacts [ gtkwave::getNumFacs ]

for {set i 0} {$i < $nfacts} {incr $1} {
    set name [gtkwave::getFacName $i]

    gtkwave::addSignalsFromList $name

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
}

gtkwave::/Edit/UnHighlight_All
gtkwave::/Time/Zoom/Zoom_Full
