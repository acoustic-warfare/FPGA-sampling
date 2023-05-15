#include <stdio.h>
#include "xil_printf.h"

#include "xparameters.h"
#include "xil_io.h"

#define AD0 0x40000000
#define AD1 0x40000004
#define AD64 0x40000100
#define AD65 0x40000104

int main()
{

   xil_printf("Hello World\n\r");

   u32 read_reg0;
   u32 rd_en_0;
   u32 rd_en_1;

   while (1)
   {
      rd_en_0 = Xil_In32(AD64);
      rd_en_1 = Xil_In32(AD65);

      if (rd_en_0 == 0 && rd_en_1 == 0)
      {
         read_reg0 = Xil_In32(AD0);
         xil_printf("%x\n", (unsigned long)read_reg0);
      }
   }

   return 0;
}
