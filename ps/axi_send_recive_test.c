#include <stdio.h>
#include "xil_printf.h"

#include "xparameters.h"
#include "xil_io.h"

#define AD1 0x43C0000
#define AD2 0x43C0001
#define AD3 0x43C0002
#define AD4 0x43C0003

int main() {

	xil_printf("Hello World\n\r");

	int i;

	u32 read_reg0;
	u32 read_reg1;
	u32 read_reg2;
	u32 read_reg3;

	while (1) {

		xil_printf("START LOOP\n");

		Xil_Out32(AD1, 0xAAAAAAAA);
		read_reg0 = Xil_In32(AD1);

		xil_printf("%x\n", (unsigned long) read_reg0);

		Xil_Out32(AD2, 0xBBBBBBBB);
		read_reg1 = Xil_In32(AD2);

		Xil_Out32(AD3, 0xCCCCCCCC);
		read_reg2 = Xil_In32(AD3);

		Xil_Out32(AD4, 0xDDDDDDDD);
		read_reg3 = Xil_In32(AD4);

		xil_printf("%x\n", (unsigned long) read_reg1);
		xil_printf("%x\n", (unsigned long) read_reg2);
		xil_printf("%x\n", (unsigned long) read_reg3);

		for (i = 0; i < 30000000; i++)
			;
		xil_printf("END LOOP\n\r");
	}

	return 0;
}
