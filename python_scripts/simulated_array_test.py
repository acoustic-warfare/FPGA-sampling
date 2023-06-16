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

header_length = 8
sampelCounter_index = 7

sampleCounterPS = [] #fixa något snyggt här som spara datan tror jab blir bäst
sampleCounterPL = []
line_index = 0
with open(file+".txt", "r") as f:
      line_count = sum(1 for i in f)
      print("go")
      lines = f.readlines()


      for i in range(0, line_count):
          print("go " + str(line_index))
          line_index += 1
          mic_values = lines[i].split()
          sampleCounterPS.append(int(mic_values[sampelCounter_index]))
       
          for i in range(1,64):
              if(mic_values[header_length + 3] != mic_values[header_length + 3 + 4 * i]):
                  print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                  print("index: " + i + " not matching! at sampleCounter: " + mic_values[sampelCounter_index] + " at line: " + line_index + " in the txt file")
                  print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
          sampleCounterPL.append(int(mic_values[11], 2))


# Extract the last two bytes from each line




print(line_count)
print(line_index)

for i in range(1, line_count - 1):
    if(sampleCounterPL[i - 1] + 1 != sampleCounterPL[i]):
        print("Problem1 : PL_counter = " + sampleCounterPL[i])
    
    if(sampleCounterPS[i - 1] + 1 != sampleCounterPS[i]):
        print("Problem2 : PS_counter = " + sampleCounterPS[i])



f.close
print("Done!")
