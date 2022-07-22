import socket
import sys

print("test 1")

UDP_IP = ".0.0."
UDP_PORT = 8081

print("test 1")

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
print("test 2")
sock.bind((UDP_IP, UDP_PORT))
print("test 3")

print("Socket: "+str(sock.getsockname()))
print("test 4")

while True:
    data, addr = sock.recvfrom(1024) # buffer size is 1024 bytes
    print(data)
    print(addr)
    sys.stdout.flush()