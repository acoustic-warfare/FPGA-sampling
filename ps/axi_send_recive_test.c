#include <stdio.h>
#include "xil_printf.h"

#include "xparameters.h"
#include "xil_io.h"

//#define MY_PWM XPAR_MY_PWM_CORE_0_S00_AXI_BASEADDR //Because of a bug in Vivado 2015.3 and 2015.4, this value is not correct.
#define AD1 0x43C00000 //This value is found in the Address editor tab in Vivado (next to Diagram tab)
#define AD2 0x43C00010
#define AD3 0x43C00100
#define AD4 0x43C00110

int main() {

	xil_printf("Hello World\n\r");

	int i;
	u32 read_reg0;
	u32 read_reg1;
	u32 read_reg2;
	u32 read_reg3;

	while (1) {

		Xil_Out32(AD1, 0xAAAAAAAA);
		read_reg0 = Xil_In32(AD1);

		Xil_Out32(AD2, 0xBBBBBBBB);
		read_reg1 = Xil_In32(AD2);

		Xil_Out32(AD3, 0xCCCCCCCC);
		read_reg2 = Xil_In32(AD3);

		Xil_Out32(AD4, 0xDDDDDDDD);
		read_reg3 = Xil_In32(AD4);

		xil_printf("%x\n", (unsigned long) read_reg0);
		xil_printf("%x\n", (unsigned long) read_reg1);
		xil_printf("%x\n", (unsigned long) read_reg2);
		xil_printf("%x\n", (unsigned long) read_reg3);

		for (i = 0; i < 30000000; i++)
			;
	}

	return 0;
}
