import socket
import sys

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

      
   #str_data = data.decode('UTF_16')

  # with open("data.txt",'wb') as binary_file:
      # udp_data = ['udp.txt',data]
     # binary_file.write(data)
      
      
   counter = counter +1

   print(counter)
  # print(data) 
   #print(addr)
   sys.stdout.flush()

  # binary_file.close()

   #print("opening file....")

   #with open("data.txt", "rb") as binary_file:
    #  data_out = binary_file.read()
    #  print(data_out)
  # i = i +1