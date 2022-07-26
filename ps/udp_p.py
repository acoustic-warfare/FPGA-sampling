import socket
import sys

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

    # print(" recived: ", data.decode('utf-8'), "\n")
    test0 = "{0:b}".format(data[0])
    test1 = "{0:b}".format(data[1])
    test2 = "{0:b}".format(data[2])
    test3 = "{0:b}".format(data[3])

    test4 = "{0:b}".format(data[4])
    test5 = "{0:b}".format(data[5])
    test6 = "{0:b}".format(data[6])
    test7 = "{0:b}".format(data[7])

    test00 = test0.zfill(8)
    test11 = test1.zfill(8)
    test22 = test2.zfill(8)
    test33 = test3.zfill(8)

    test44 = test4.zfill(8)
    test55 = test5.zfill(8)
    test66 = test6.zfill(8)
    test77 = test7.zfill(8)

    test_full = test33 + test22 + test11 + test00
    test_full2 = test77 + test66 + test55 + test44
    #print("test_full: ", test_full)

    out = twos_comp(int(test_full, 2), len(test_full))
    out2 = twos_comp(int(test_full2, 2), len(test_full2))
    print("1: ", out)
    print("2: ", out2)

    sys.stdout.flush()
