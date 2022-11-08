import itertools
import logging
import socket
import sys
import struct
import time 
from ctypes import Structure, c_byte, c_int32, sizeof


# NOTE: Check if big-endian or little-endian as this is often flipped
# use:
# from ctypes import LittleEndianStructure, BigEndianStructure
# and replace Structure with LittleEndianStructure or BigEndianStructure to get the right one.
class Data(Structure):
    _fields_ = [
        ("arrayId", c_int32),  
        ("protocolVer", c_int32),  # The data we care about
        ("frequency", c_int32),
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
    ]
UDP_IP = "0.0.0.0"
UDP_PORT = 21844

print("Enter a filename to sample: ")
fileChooser = input()
print("Enter time to record (seconds): ")
recordTime=input()
t_end = time.time()+int(recordTime)


"""Receive packages forever"""
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))

# itertools.count() is a generator that counts up forever.
# same as while True with the added benefit of keeping track of the number of iterations.
# Can be converted to a while True if count is unused.
with open(fileChooser, "wb") as f:

   #for count in itertools.count():
   while time.time()<t_end:
      data = sock.recv(sizeof(Data))
      
      d = Data.from_buffer_copy(data)
      f.write(d)

    

      

f.close
sys.stdout.flush()
   

