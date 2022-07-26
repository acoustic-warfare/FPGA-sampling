
import sys

print("test 1")

i=0
counter = 0




while( counter < 3593):
   # print(counter)
   # print(data) 
      #print(addr)
   sys.stdout.flush()

   # binary_file.close()

   #print("opening file....")

   with open("data.txt", "rb") as binary_file:
      data_out = binary_file.read()
      print(data_out)
   
   counter = counter + 1