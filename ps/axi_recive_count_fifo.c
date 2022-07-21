#include <stdio.h>
#include "xil_printf.h"

#include "xparameters.h"
#include "xil_io.h"

#define AD0 0x40000000
#define AD1 0x40000004

int main()
{

   xil_printf("Hello World\n\r");

   u32 read_reg0;

   while (1)
   {
      read_reg0 = Xil_In32(AD0);
      xil_printf("%x\n", (unsigned long)read_reg0);
      read_reg0 = Xil_In32(AD1);
   }

   return 0;
}