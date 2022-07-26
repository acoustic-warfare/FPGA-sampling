from pickle import FALSE
import socket
import sys
from io import BytesIO
import tempfile
import struct
import numpy 
from bitstring import BitArray
from pkg_resources import to_filename

print("test 1")

UDP_IP = "0.0.0.0"
UDP_PORT = 21844

print("test 1")

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
print("test 2")
sock.bind((UDP_IP, UDP_PORT))
print("test 3")

print("Socket: "+str(sock.getsockname()))
print("test 4")


i=0
counter = 0
while 1:

   data, addr = sock.recvfrom(1024) # buffer size is 1024 bytes

   #tmp = bytes.fromhex(data[0])
   
   #def twos_comp(val,bits):
   #   if(val & (1 << (bits-1))) !=0:
   #      val = val- (1 << bits)
   #   return val

   ###############################################

   def _to_int(val,nbits):
      i = int(val,32)
      if i >= 2 ** (nbits -1):
         i -= 2** nbits
      return i
   
   print(_to_int(data,16))
   print(_to_int(data,32))

   #out = twos_comp(int(data[0],2), len(data))
   #print(val)
   int_val = int.from_bytes(data, "little")

   print(int_val)

   #mylist=(data[0],data[1],data[2],data[3])
   #test_ivar = BitArray(int_val)
   #print(test_ivar)

   #sys.stdout.buffer.write(data)


   #mylist=(data[0],data[1],data[2],data[3])


   #tempfile.TemporaryFile().write(data)
   #str_data1 = data[0].decode('utf-16')
   #f=open("data.txt","wb")
   #f.write(data)
   #f.close
  # print(mylist)
   #tmp= bytearray(mylist)
   #print struct.unpack('<f',tmp)
   #str_data = data.decode(data[0])

   #tmp = struct.unpack('f',data)

   #tmp = int(tmp)
   #open("data.txt",'wb').write(data)
      # udp_data = ['udp.txt',data]
     # binary_file.write(data)
   #with open("data.txt","a") as fd:
    #  for d in tmp:
     #    fd.writelines(str(d))
      #   fd.writelines("\n")
   #print(tmp)  
  # counter = counter +1

   #print(str_data1)
  # print(data) 
   #print(addr)
   sys.stdout.flush()

  # binary_file.close()

   #print("opening file....")

   #with open("data.txt", "rb") as binary_file:
     # data_out = binary_file.read()
    #  print(data_out)
  # i = i +1
   #print(counter)