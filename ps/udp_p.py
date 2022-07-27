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

# 0
    bits00 = "{0:b}".format(data[0])
    bits01 = "{0:b}".format(data[1])
    bits02 = "{0:b}".format(data[2])
    bits03 = "{0:b}".format(data[3])

    samp00 = bits00.zfill(8)
    samp01 = bits01.zfill(8)
    samp02 = bits02.zfill(8)
    samp03 = bits03.zfill(8)

    full0 = samp03 + samp02 + samp01 + samp00
####
# 1
    bits10 = "{0:b}".format(data[4])
    bits11 = "{0:b}".format(data[5])
    bits12 = "{0:b}".format(data[6])
    bits13 = "{0:b}".format(data[7])

    samp10 = bits10.zfill(8)
    samp11 = bits11.zfill(8)
    samp12 = bits12.zfill(8)
    samp13 = bits13.zfill(8)

    full1 = samp13 + samp12 + samp11 + samp10
####
# 2
    bits20 = "{0:b}".format(data[8])
    bits21 = "{0:b}".format(data[9])
    bits22 = "{0:b}".format(data[10])
    bits23 = "{0:b}".format(data[11])

    samp20 = bits20.zfill(8)
    samp21 = bits21.zfill(8)
    samp22 = bits22.zfill(8)
    samp23 = bits23.zfill(8)

    full2 = samp23 + samp22 + samp21 + samp20
####
# 3
    bits30 = "{0:b}".format(data[12])
    bits31 = "{0:b}".format(data[13])
    bits32 = "{0:b}".format(data[14])
    bits33 = "{0:b}".format(data[15])

    samp30 = bits30.zfill(8)
    samp31 = bits31.zfill(8)
    samp32 = bits32.zfill(8)
    samp33 = bits33.zfill(8)

    full3 = samp33 + samp32 + samp31 + samp30
####
# 4
    bits40 = "{0:b}".format(data[16])
    bits41 = "{0:b}".format(data[17])
    bits42 = "{0:b}".format(data[18])
    bits43 = "{0:b}".format(data[19])

    samp40 = bits40.zfill(8)
    samp41 = bits41.zfill(8)
    samp42 = bits42.zfill(8)
    samp43 = bits43.zfill(8)

    full4 = samp43 + samp42 + samp41 + samp40

    out0 = twos_comp(int(full0, 2), len(full0))
    out1 = twos_comp(int(full1, 2), len(full1))
    out2 = twos_comp(int(full2, 2), len(full2))
    out3 = twos_comp(int(full3, 2), len(full3))
    out4 = twos_comp(int(full4, 2), len(full4))

    print("0: ", full0)
    print("0: ", out0)

    print("1: ", full1)
    print("1: ", out1)

    print("2: ", full2)
    print("2: ", out2)

    print("3: ", full3)
    print("3: ", out3)

    print("4: ", full4)
    print("4: ", out4)

    out_str0 = str(out0)
    out_str1 = str(out1)
    out_str2 = str(out2)
    out_str3 = str(out3)
    out_str4 = str(out4)

    with open("data.txt", "a") as f:
        f.write(out_str0)
        f.write("\n")
        f.write(out_str1)
        f.write("\n")
        f.write(out_str2)
        f.write("\n")
        f.write(out_str3)
        f.write("\n")
        f.write(out_str4)
        f.write("\n")

    sys.stdout.flush()
