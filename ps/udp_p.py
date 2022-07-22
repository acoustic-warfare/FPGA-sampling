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




while 1:

   data, addr = sock.recvfrom(1024) # buffer size is 1024 bytes

   b_data = data
   str_data = b_data.decode('UTF_16')

   with open('data.txt','wb') as f:
     # udp_data = ['udp.txt',data]
      f.write(data)
   
   
   
   print(data) 
   print(addr)
   sys.stdout.flush()