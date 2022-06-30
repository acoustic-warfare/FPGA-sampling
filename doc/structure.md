

General:
Sample frequency 125 MHz (the clock that is used for the varius components in the FPGA and called clk in all our components)
Data frequency 25 MHz (the frequency that data is sent by the array called fsck or sck)
Mic sample frequency 48,828 KHz (the frequency at wich the microfones sample new data called fs or ws)

# test for test 




Components:
sample
collectorn
full_sample


Wrappers:
sample_machine
sample_block




   sample:
Sample is the component closest to the mic array. The componenet samples the data at 125 MHz wich is five times faster than the data frequency. 

   collectorn:
Collectorn collects the arrays and puts them in to a matrix that has the size of 16 by 24 wich is equvalent to a full sample from one track. 

   full_sample:
Full_sample collects four matrixes from four diffrent collectors and puts the in to one 64 by 24 matrix. This matrix holds all the data for the
current sample.




   collect_sample:
Collect_sample connects four collector components to one full_sample

   sampel_block:
Full_sample is the wrapper for collect_sample and sample. The block contains four sample componenets and one collect_sample component. 















