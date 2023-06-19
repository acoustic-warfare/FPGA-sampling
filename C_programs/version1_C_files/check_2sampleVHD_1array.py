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


with open(file_name, 'r') as f:
    lines = [line for line in f]

    line_count = 0

    for line in lines:
       line_count += 1
       mic_values = line.split()
       #print(mic_values[sampelCounter_index])

       
       for i in range(0,57):
          if(mic_values[header_length+2 + i * 6]!= mic_values[header_length+5 + i * 6]):
              print("!!!!!!!!!!!!!!!!!!!!!!!!")
              print(str(line_count) + "   " + str(mic_values[header_length+2 + i * 6 - 2]) + " " + str(mic_values[header_length+5 + i * 6 - 2]))
              print("!!!!!!!!!!!!!!!!!!!!!!!!")
