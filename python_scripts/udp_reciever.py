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
        ("mic_75", c_int32),
        ("mic_76", c_int32),
        ("mic_77", c_int32),
        ("mic_78", c_int32),
        ("mic_79", c_int32),    
        ("mic_70", c_int32),
        ("mic_81", c_int32),
        ("mic_82", c_int32),
        ("mic_83", c_int32),
        ("mic_84", c_int32),
        ("mic_85", c_int32),
        ("mic_86", c_int32),
        ("mic_87", c_int32),
        ("mic_88", c_int32),
        ("mic_89", c_int32),
        ("mic_90", c_int32),
        ("mic_91", c_int32),
        ("mic_92", c_int32),
        ("mic_93", c_int32),
        ("mic_94", c_int32),
        ("mic_95", c_int32),
        ("mic_96", c_int32),
        ("mic_97", c_int32),
        ("mic_98", c_int32),
        ("mic_99", c_int32),
        ("mic_100", c_int32),
        ("mic_101", c_int32),
        ("mic_102", c_int32),
        ("mic_103", c_int32),
        ("mic_104", c_int32),
        ("mic_105", c_int32),
        ("mic_106", c_int32),
        ("mic_107", c_int32),
        ("mic_108", c_int32),
        ("mic_109", c_int32),
        ("mic_110", c_int32),
        ("mic_111", c_int32),
        ("mic_112", c_int32),
        ("mic_113", c_int32),
        ("mic_114", c_int32),
        ("mic_115", c_int32),
        ("mic_116", c_int32),
        ("mic_117", c_int32),
        ("mic_118", c_int32),
        ("mic_119", c_int32),
        ("mic_120", c_int32),
        ("mic_121", c_int32),
        ("mic_122", c_int32),
        ("mic_123", c_int32),
        ("mic_124", c_int32),
        ("mic_125", c_int32),
        ("mic_126", c_int32),
        ("mic_127", c_int32),
        ("mic_128", c_int32),
        ("mic_129", c_int32),
        ("mic_130", c_int32),
        ("mic_131", c_int32),
        ("mic_132", c_int32),
        ("mic_133", c_int32),
        ("mic_134", c_int32),
        ("mic_135", c_int32),
        ("mic_136", c_int32),
        ("mic_137", c_int32),
        ("mic_138", c_int32),
        ("mic_139", c_int32),
        ("mic_140", c_int32),
        ("mic_141", c_int32),
        ("mic_142", c_int32),
        ("mic_143", c_int32),
        ("mic_144", c_int32),
        ("mic_145", c_int32),
        ("mic_146", c_int32),
        ("mic_147", c_int32),
        ("mic_148", c_int32),
        ("mic_149", c_int32),
        ("mic_150", c_int32),
        ("mic_151", c_int32),
        ("mic_152", c_int32),
        ("mic_153", c_int32),
        ("mic_154", c_int32),
        ("mic_155", c_int32),
        ("mic_156", c_int32),
        ("mic_157", c_int32),
        ("mic_158", c_int32),
        ("mic_159", c_int32),
        ("mic_160", c_int32),
        ("mic_161", c_int32),
        ("mic_162", c_int32),
        ("mic_163", c_int32),
        ("mic_164", c_int32),      
        ("mic_165", c_int32),
        ("mic_166", c_int32),
        ("mic_167", c_int32),
        ("mic_168", c_int32),
        ("mic_169", c_int32),
        ("mic_170", c_int32),
        ("mic_171", c_int32),
        ("mic_172", c_int32),
        ("mic_173", c_int32),
        ("mic_174", c_int32),
        ("mic_175", c_int32),
        ("mic_176", c_int32),
        ("mic_177", c_int32),
        ("mic_178", c_int32),
        ("mic_179", c_int32),    
        ("mic_170", c_int32),
        ("mic_181", c_int32),
        ("mic_182", c_int32),
        ("mic_183", c_int32),
        ("mic_184", c_int32),
        ("mic_185", c_int32),
        ("mic_186", c_int32),
        ("mic_187", c_int32),
        ("mic_188", c_int32),
        ("mic_189", c_int32),
        ("mic_190", c_int32),
        ("mic_191", c_int32),
        ("mic_192", c_int32),
        ("mic_193", c_int32),
        ("mic_194", c_int32),
        ("mic_195", c_int32),
        ("mic_196", c_int32),
        ("mic_197", c_int32),
        ("mic_198", c_int32),
        ("mic_199", c_int32),  
        ("mic_200", c_int32),
        ("mic_201", c_int32),
        ("mic_202", c_int32),
        ("mic_203", c_int32),
        ("mic_204", c_int32),
        ("mic_205", c_int32),
        ("mic_206", c_int32),
        ("mic_207", c_int32),
        ("mic_208", c_int32),
        ("mic_209", c_int32),
        ("mic_210", c_int32),
        ("mic_211", c_int32),
        ("mic_212", c_int32),
        ("mic_213", c_int32),
        ("mic_214", c_int32),
        ("mic_215", c_int32),
        ("mic_216", c_int32),
        ("mic_217", c_int32),
        ("mic_218", c_int32),
        ("mic_219", c_int32),
        ("mic_220", c_int32),
        ("mic_221", c_int32),
        ("mic_222", c_int32),
        ("mic_223", c_int32),
        ("mic_224", c_int32),
        ("mic_225", c_int32),
        ("mic_226", c_int32),
        ("mic_227", c_int32),
        ("mic_228", c_int32),
        ("mic_229", c_int32),
        ("mic_230", c_int32),
        ("mic_231", c_int32),
        ("mic_232", c_int32),
        ("mic_233", c_int32),
        ("mic_234", c_int32),
        ("mic_235", c_int32),
        ("mic_236", c_int32),
        ("mic_237", c_int32),
        ("mic_238", c_int32),
        ("mic_239", c_int32),
        ("mic_240", c_int32),
        ("mic_241", c_int32),
        ("mic_242", c_int32),
        ("mic_243", c_int32),
        ("mic_244", c_int32),
        ("mic_245", c_int32),
        ("mic_246", c_int32),
        ("mic_247", c_int32),
        ("mic_248", c_int32),
        ("mic_249", c_int32),
        ("mic_250", c_int32),
        ("mic_251", c_int32),
        ("mic_252", c_int32),
        ("mic_253", c_int32),
        ("mic_254", c_int32),
        ("mic_255", c_int32),
        ("mic_256", c_int32),
    ]
UDP_IP = "0.0.0.0"
UDP_PORT = 21844

print("Enter a filename for the recording: ")
#fileChooser = input()
fileChooser = "ljud"
print("Save as txt? (y) ")
#txtInput = input()
txtInput = 'n'
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
            data = sock.recv(1458)

            d = Data.from_buffer_copy(data)

            # Printing the first parts
            f.write("header: " + str(d.header) + " ")
            f.write("header: " + int_to_twos_complement_string(d.header) + "        ")
         
            f.write("   sampelCounter: " + str(d.sampelCounter) + " ")
            f.write("   sampelCounter: " + int_to_twos_complement_string_16bit(d.sampelCounter) + "        ")

            # Printing each mic data as integers
            for i in range(1, 256):
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
         data = sock.recv(1458)

         d = Data.from_buffer_copy(data)
         f.write(d)

    

      

f.close
sys.stdout.flush()
print("Done!")
   

