#include <stdio.h>
#include "xil_printf.h"

#include "xparameters.h"
#include "xil_io.h"

#define AD0 0x40000000
#define AD1 0x40000004
#define AD2 0x40000008
#define AD3 0x4000000B


int main()
{

   xil_printf("Hello World\n\r");

   u32 read_reg0;

   while (1)
   {
      read_reg0 = Xil_In32(AD0);
      xil_printf("%x\n", (unsigned long)read_reg0);
      read_reg0 = Xil_In32(AD1);
      xil_printf("%x\n", (unsigned long)read_reg0);
      read_reg0 = Xil_In32(AD2);
      xil_printf("%x\n", (unsigned long)read_reg0);
      read_reg0 = Xil_In32(AD3);
      xil_printf("%x\n", (unsigned long)read_reg0);
   }

   return 0;
}
