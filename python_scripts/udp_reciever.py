import itertools
import logging
import socket
import sys
import struct
import time 
import os
from ctypes import Structure, c_byte, c_int32, sizeof






def int_to_twos_complement_string(num):
    if num >= 0:
        binary = bin(num)[2:]  # Convert to binary string excluding the '0b' prefix
        binary = binary.zfill(32)  # Pad with leading zeros to ensure 32 bits
        binary_with_spaces = ' '.join(binary[i:i+8] for i in range(0, 32, 8))  # Add space between each byte
    else:
        # Convert to positive form by flipping the bits and adding 1
        positive_num = abs(num) - 1
        binary = bin(positive_num)[2:]  # Convert to binary string excluding the '0b' prefix
        binary = binary.zfill(32)  # Pad with leading zeros to ensure 32 bits
        
        # Flip the bits
        inverted_binary = ''.join('1' if bit == '0' else '0' for bit in binary)
        
        binary_with_spaces = ' '.join(inverted_binary[i:i+8] for i in range(0, 32, 8))  # Add space between each byte
    binary_with_spaces = binary_with_spaces[:26] + binary_with_spaces[27:]  # Remove space between last two bytes
    return binary_with_spaces

def int_to_twos_complement_string_16bit(num):
    if num >= 0:
        binary = bin(num)[2:]  # Convert to binary string excluding the '0b' prefix
        binary = binary.zfill(32)  # Pad with leading zeros to ensure 32 bits
    else:
        # Convert to positive form by flipping the bits and adding 1
        positive_num = abs(num) - 1
        binary = bin(positive_num)[2:]  # Convert to binary string excluding the '0b' prefix
        binary = binary.zfill(32)  # Pad with leading zeros to ensure 32 bits
        
    binary = binary[16:]  # Remove space between last two bytes
    return binary



# NOTE: Check if big-endian or little-endian as this is often flipped
# use:
# from ctypes import LittleEndianStructure, BigEndianStructure
# and replace Structure with LittleEndianStructure or BigEndianStructure to get the right one.
class Data(Structure):
    _fields_ = [
        ("header", c_int32),  
        ("sampelCounter", c_int32),
        ("mic_1", c_int32),
        ("mic_2", c_int32),
        ("mic_3", c_int32),
        ("mic_4", c_int32),
        ("mic_5", c_int32),
        ("mic_6", c_int32),
        ("mic_7", c_int32),
        ("mic_8", c_int32),
        ("mic_9", c_int32),
        ("mic_10", c_int32),
        ("mic_11", c_int32),
        ("mic_12", c_int32),
        ("mic_13", c_int32),
        ("mic_14", c_int32),
        ("mic_15", c_int32),
        ("mic_16", c_int32),
        ("mic_17", c_int32),
        ("mic_18", c_int32),
        ("mic_19", c_int32),
        ("mic_20", c_int32),
        ("mic_21", c_int32),
        ("mic_22", c_int32),
        ("mic_23", c_int32),
        ("mic_24", c_int32),
        ("mic_25", c_int32),
        ("mic_26", c_int32),
        ("mic_27", c_int32),
        ("mic_28", c_int32),
        ("mic_29", c_int32),
        ("mic_30", c_int32),
        ("mic_31", c_int32),
        ("mic_32", c_int32),
        ("mic_33", c_int32),
        ("mic_34", c_int32),
        ("mic_35", c_int32),
        ("mic_36", c_int32),
        ("mic_37", c_int32),
        ("mic_38", c_int32),
        ("mic_39", c_int32),
        ("mic_40", c_int32),
        ("mic_41", c_int32),
        ("mic_42", c_int32),
        ("mic_43", c_int32),
        ("mic_44", c_int32),
        ("mic_45", c_int32),
        ("mic_46", c_int32),
        ("mic_47", c_int32),
        ("mic_48", c_int32),
        ("mic_49", c_int32),
        ("mic_50", c_int32),
        ("mic_51", c_int32),
        ("mic_52", c_int32),
        ("mic_53", c_int32),
        ("mic_54", c_int32),
        ("mic_55", c_int32),
        ("mic_56", c_int32),
        ("mic_57", c_int32),
        ("mic_58", c_int32),
        ("mic_59", c_int32),
        ("mic_60", c_int32),
        ("mic_61", c_int32),
        ("mic_62", c_int32),
        ("mic_63", c_int32),
        ("mic_64", c_int32),      
        ("mic_65", c_int32),
        ("mic_66", c_int32),
        ("mic_67", c_int32),
        ("mic_68", c_int32),
        ("mic_69", c_int32),
        ("mic_70", c_int32),
        ("mic_71", c_int32),
        ("mic_72", c_int32),
        ("mic_73", c_int32),
        ("mic_74", c_int32),      
    ]
UDP_IP = "0.0.0.0"
UDP_PORT = 21844

print("Enter a filename for the recording: ")
fileChooser = input()
print("Save as txt? (y) ")
txtInput=input()
print("Enter time to record (seconds): ")
recordTime=input()
t_end = time.time()+int(recordTime)


"""Receive packages forever"""
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))

# itertools.count() is a generator that counts up forever.
# same as while True with the added benefit of keeping track of the number of iterations.
# Can be converted to a while True if count is unused.
# ROOT +'/array_PCBA1_recordings/'+fileChooser
# ROOT +'/arrat_pcba2_small_text_recordings/'+fileChooser
# ROOT +'/array_PCBA2_BOLD_recordings/'+fileChooser

ROOT = os.getcwd()

if(txtInput.lower() == "y"):
      print("Recording!!")
      with open(fileChooser+".txt", "w") as f:
         while time.time()<t_end:
            data = sock.recv(sizeof(Data))

            d = Data.from_buffer_copy(data)

            # Printing the first parts
            f.write("header: " + str(d.header) + " ")
            f.write("header: " + int_to_twos_complement_string(d.header) + "        ")
         
            f.write("   sampelCounter: " + str(d.sampelCounter) + " ")
            f.write("   sampelCounter: " + int_to_twos_complement_string_16bit(d.sampelCounter) + "        ")

            # Printing each mic data as integers
            for i in range(1, 75):
               field_name = f"mic_{i}"
               mic_data = int_to_twos_complement_string(getattr(d, field_name))
               f.write(field_name + ": ")
               f.write(mic_data + "    ")
            f.write("\n")
   
else:
   print("Recording")
   with open(fileChooser, "wb") as f:
      #for count in itertools.count():
      while time.time()<t_end:
         data = sock.recv(sizeof(Data))

         d = Data.from_buffer_copy(data)
         f.write(d)

    

      

f.close
sys.stdout.flush()
print("Done!")
   

