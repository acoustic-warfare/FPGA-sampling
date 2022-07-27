from pickle import FALSE
import socket
import sys
from io import BytesIO
import tempfile
import struct
import numpy
from pkg_resources import to_filename

print("START")

UDP_IP = "0.0.0.0"
UDP_PORT = 21844


sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

sock.bind((UDP_IP, UDP_PORT))


print("Socket: "+str(sock.getsockname()))


def twos_comp(val, bits):
    if(val & (1 << (bits - 1))) != 0:
        val = val - (1 << bits)
    return val


while 1:

    data, addr = sock.recvfrom(1024)  # buffer size is 1024 bytes

    for i in range(10):
        bits00 = "{0:b}".format(data[i*4])
        bits01 = "{0:b}".format(data[i*4+1])
        bits02 = "{0:b}".format(data[i*4+2])
        bits03 = "{0:b}".format(data[i*4+3])

        samp00 = bits00.zfill(8)
        samp01 = bits01.zfill(8)
        samp02 = bits02.zfill(8)
        samp03 = bits03.zfill(8)

        full0 = samp03 + samp02 + samp01 + samp00

        out0 = twos_comp(int(full0, 2), len(full0))

        print(i, ": ", full0)
        print(i, ": ", out0)

        out_str0 = str(out0)

        # with open("data.txt", "a") as f:
        #    f.write(out_str0)
        #    f.write("\n")

    sys.stdout.flush()
