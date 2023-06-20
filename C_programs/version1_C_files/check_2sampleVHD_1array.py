import itertools
import logging
import socket
import sys
import struct
import time 
import os



ROOT = os.getcwd()

file_name="C_programs/version1_C_files/new_sample_data_new.txt"

header_length = 7
sampelCounter_index = 6
sampleMics = []

print("2 Arrays? [y/n]")
if(input().lower() == "y"):
    arrays2 = True
else:   
    arrays2 = False


sampleCounterPS = []

with open(file_name, 'r') as f:
    lines = [line for line in f]

    line_count = 0

    for line in lines:
       line_count += 1
       mic_values = line.split()
       #print(mic_values[sampelCounter_index])

       if(arrays2):
          for i in range(0,57):
             if(mic_values[header_length+2 + i * 6]!= mic_values[header_length+5 + i * 6]):
                 print("!!!!!!!!!!!!!!!!!!!!!!!!")
                 print(str(line_count) + "   " + str(mic_values[header_length+2 + i * 6 - 2]) + " " + str(mic_values[header_length+5 + i * 6 - 2]))
                 print("!!!!!!!!!!!!!!!!!!!!!!!!")
       else:
            sampleCounterPS.append(int(mic_values[sampelCounter_index][:-1] ))
            #print(sampleCounterPS[line_count - 1])


if(arrays2 == False):
    skipps = 0
    for i in range(1, line_count):
         if(sampleCounterPS[i - 1] + 1 != sampleCounterPS[i]):
             print("Problem1 at line: " + str(i) + ", " + str(i+1) + " in the txt file, jump: " + str(abs(sampleCounterPS[i - 1] - sampleCounterPS[i])) + " places")
             skipps += 1
    print(skipps)
