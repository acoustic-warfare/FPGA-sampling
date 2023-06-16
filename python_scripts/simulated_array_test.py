import itertools
import logging
import socket
import sys
import struct
import time 
import os



ROOT = os.getcwd()

print("Enter name of file to analyze: ")
file=input()

print("Simulated data from a FPGA? [y/n]")
if(input().lower() == "y"):
    simulated = True
else:   
    simulated = False

header_length = 8
sampelCounter_index = 7

sampleCounterPS = [] #fixa något snyggt här som spara datan tror jab blir bäst
sampleCounterPL = []
line_index = 0
with open(file+".txt") as f:
    lines = [line for line in f]

    line_count = 0

    for line in lines:
       line_count += 1
       mic_values = line.split()
       sampleCounterPS.append(int(mic_values[sampelCounter_index]))
       if(simulated):
          for i in range(1,64):
             if(mic_values[header_length + 3] != mic_values[header_length + 3 + 4 * i]):
                 print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                 print("index: " + i + " not matching! at sampleCounter: " + mic_values[sampelCounter_index] + " at line: " + line_index + " in the txt file")
                 print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
          sampleCounterPL.append(int(mic_values[11], 2))







print(line_count)
print(len(sampleCounterPS))

for i in range(1, line_count):
    if(simulated):
       if(sampleCounterPL[i - 1] + 1 != sampleCounterPL[i] and sampleCounterPS[i - 1] + 1 != sampleCounterPS[i]):
           print("Problem1 at line: " + str(i) + ", " + str(i+1) + " in the txt file, jump: " + str(abs(sampleCounterPS[i - 1] - sampleCounterPS[i])) + " places")
       elif(sampleCounterPL[i - 1] + 1 != sampleCounterPL[i]):
           print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
           print("Problem2 : PL_counter = " + str(sampleCounterPL[i]) + " at line: " + str(i) + ", " + str(i+1) + " in the txt file")
           print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
       elif(sampleCounterPS[i - 1] + 1 != sampleCounterPS[i]):
           print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
           print("Problem3 : PS_counter = " + str(sampleCounterPS[i]) + " at line: " + str(i) + ", " + str(i+1) + " in the txt file")
           print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    else: 
        if(sampleCounterPS[i - 1] + 1 != sampleCounterPS[i]):
            print("Problem1 at line: " + str(i) + ", " + str(i+1) + " in the txt file, jump: " + str(abs(sampleCounterPS[i - 1] - sampleCounterPS[i])) + " places")


f.close
print("Done!")
