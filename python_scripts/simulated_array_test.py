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

print("Simulated data from same FPGA? [y/n]")
if(input().lower() == "y"):
    simulated = True
else:   
    simulated = False

header_length = 8
sampelCounter_index = 7

sampleCounterPS = [] #fixa något snyggt här som spara datan tror jab blir bäst
sampleCounterPL = []
line_index = 0
wrong = 1
line_count = 1

with open(file+".txt") as f:
    lines = [line for line in f]


    for line in lines:
       line_count += 1
       mic_values = line.split()
       if(simulated):
          if(mic_values[71] != mic_values[72]):
             wrong += 1

print("antal samples: " + str(line_count))
print("antal fel: " + str(wrong))
print("fel: " + "%.3f" % (wrong / line_count * 100) + "%")










f.close
print("Done!")
