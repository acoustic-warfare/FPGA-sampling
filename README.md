Welcome to the Acoustic Warfare FPGA-samling github!

Information about the project and user guid on how to build and run the project is found under the [Project Wiki](../../wiki).

A more comprehencive discription of all the diffrent components of the project can be found in the [Project Report](/doc/acoustic_warfare_fpga_sampling.pdf).

See usermanual at https://github.com/IvarNilsson/FPGA-sampling/wiki/User-Manual

How to test the arrays, see the [Test Manual](/doc/Testing_the_arrays_version_1.pdf). Download the Test Manual to see the included links at page 2.

All test and results were done on PCB-A1 version one (the version without buffers).

The following block diagram showcase a simplification of the flow from the microphone array to a receiving CPU
![](https://github.com/IvarNilsson/FPGA-sampling/blob/main/doc/pictures/flowchart.png)


Order of how how microphones is received on a CPU and their actual position on the array
![](https://github.com/IvarNilsson/FPGA-sampling/blob/main/doc/pictures/array_instruction.png)
