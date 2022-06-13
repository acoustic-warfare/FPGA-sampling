set nfacts [ gtkwave::getNumFacs ]

for {set i 0} {$i < $nfacts} {incr $1} {
    set name [gtkwave::getFacName $i]
    gtkwave::addSignalsFromList $name
}