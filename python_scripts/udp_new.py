import socket
import time 
import os

def ints_to_twos_complement_string(a, b, c, d):
    binary_strings = []
    numbers = [a, b, c, d]

    for number in numbers:
        # Convert the number to its binary representation
        binary = bin(number & 0xFF)[2:].zfill(8)

        # Check if the number is negative (bit 7 is set)
        if number < 0:
            # Take the two's complement by inverting all bits and adding 1
            binary = ''.join('1' if bit == '0' else '0' for bit in binary)
            binary = binary[-8:]
            binary = bin(int(binary, 2) + 1)[2:].zfill(8)

        binary_strings.append(binary)

    # Join the binary strings with a space, except for the last two sections
    result = binary_strings[-4] + ' ' + binary_strings[-3] + ' ' + binary_strings[-2] + binary_strings[-1]
    return result

UDP_IP = "0.0.0.0"
UDP_PORT = 21844

print("Enter a filename for the recording: ")
fileChooser = "data"
#fileChooser = input()
print("Save as txt? (y) ")
txtInput="y"
#txtInput=input()
print("Enter time to record (seconds): ")
recordTime = 1
#recordTime=input()
t_end = time.time()+int(recordTime)

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
sock.bind((UDP_IP, UDP_PORT))

ROOT = os.getcwd()

if(txtInput.lower() == "y"):
   print("Recording!!")
   with open(fileChooser+".txt", "w") as f:
      while time.time()<t_end:
         data = sock.recv(1600)

         f.write("Header:  " + ints_to_twos_complement_string(data[3], data[2], data[1], data[0]) + "    ")
         
         f.write("   sampelCounter: " + ints_to_twos_complement_string(data[3 + 4], data[2 + 4], data[1 + 4], data[0 + 4]) + "      ")

         for i in range(2, 212):
            f.write("Mic" + str(i - 1) + ": ")
            f.write(ints_to_twos_complement_string(data[3 + i * 4], data[2 + i* 4], data[1 + i*4], data[0 + i*4]) + "    ")
         f.write("\n")

print("Done!")