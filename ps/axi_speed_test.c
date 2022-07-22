#include <stdio.h>
#include "xil_printf.h"

#include "xparameters.h"
#include "xil_io.h"

#define AD0 0x40000000
#define AD1 0x40000004
#define AD2 0x40000008
#define AD3 0x4000000C
#define AD4 0x40000010
#define AD5 0x40000014
#define AD6 0x40000018
#define AD7 0x4000001C
#define AD8 0x40000020
#define AD9 0x40000024
#define AD10 0x40000028
#define AD11 0x4000002C
#define AD12 0x40000030
#define AD13 0x40000034
#define AD14 0x40000038
#define AD15 0x4000003C
#define AD16 0x40000040
#define AD17 0x40000044
#define AD18 0x40000048
#define AD19 0x4000004C
#define AD20 0x40000050
#define AD21 0x40000054
#define AD22 0x40000058
#define AD23 0x4000005C
#define AD24 0x40000060
#define AD25 0x40000064
#define AD26 0x40000068
#define AD27 0x4000006C
#define AD28 0x40000070
#define AD29 0x40000074
#define AD30 0x40000078
#define AD31 0x4000007C
#define AD32 0x40000080
#define AD33 0x40000084
#define AD34 0x40000088
#define AD35 0x4000008C
#define AD36 0x40000090
#define AD37 0x40000094
#define AD38 0x40000098
#define AD39 0x4000009C
#define AD40 0x400000A0
#define AD41 0x400000A4
#define AD42 0x400000A8
#define AD43 0x400000AC
#define AD44 0x400000B0
#define AD45 0x400000B4
#define AD46 0x400000B8
#define AD47 0x400000BC
#define AD48 0x400000C0
#define AD49 0x400000C4
#define AD50 0x400000C8
#define AD51 0x400000CC
#define AD52 0x400000D0
#define AD53 0x400000D4
#define AD54 0x400000D8
#define AD55 0x400000DC
#define AD56 0x400000E0
#define AD57 0x400000E4
#define AD58 0x400000E8
#define AD59 0x400000EC
#define AD60 0x400000F0
#define AD61 0x400000F4
#define AD62 0x400000F8
#define AD63 0x400000FC

#define AD64 0x40000100
#define AD65 0x40000104

int main() {

	xil_printf("Hello World\n\r");

	u32 read_reg0;
	u32 read_reg1;
	u32 read_reg2;
	u32 read_reg3;
	u32 read_reg4;
	u32 read_reg5;
	u32 read_reg6;
	u32 read_reg7;
	u32 read_reg8;
	u32 read_reg9;

	u32 read_reg10;
	u32 read_reg11;
	u32 read_reg12;
	u32 read_reg13;
	u32 read_reg14;
	u32 read_reg15;
	u32 read_reg16;
	u32 read_reg17;
	u32 read_reg18;
	u32 read_reg19;

	u32 read_reg20;
	u32 read_reg21;
	u32 read_reg22;
	u32 read_reg23;
	u32 read_reg24;
	u32 read_reg25;
	u32 read_reg26;
	u32 read_reg27;
	u32 read_reg28;
	u32 read_reg29;

	u32 read_reg30;
	u32 read_reg31;
	u32 read_reg32;
	u32 read_reg33;
	u32 read_reg34;
	u32 read_reg35;
	u32 read_reg36;
	u32 read_reg37;
	u32 read_reg38;
	u32 read_reg39;

	u32 read_reg40;
	u32 read_reg41;
	u32 read_reg42;
	u32 read_reg43;
	u32 read_reg44;
	u32 read_reg45;
	u32 read_reg46;
	u32 read_reg47;
	u32 read_reg48;
	u32 read_reg49;

	u32 read_reg50;
	u32 read_reg51;
	u32 read_reg52;
	u32 read_reg53;
	u32 read_reg54;
	u32 read_reg55;
	u32 read_reg56;
	u32 read_reg57;
	u32 read_reg58;
	u32 read_reg59;

	u32 read_reg60;
	u32 read_reg61;
	u32 read_reg62;
	u32 read_reg63;

	u32 rd_en_0;
	u32 rd_en_1;

	while (1) {
		//rd_en_0 = Xil_In32(AD64);
		//rd_en_1 = Xil_In32(AD65);

		//if (rd_en_0 == 0 && rd_en_1 == 0) {
		read_reg0 = Xil_In32(AD0);
		read_reg1 = Xil_In32(AD1);
		read_reg2 = Xil_In32(AD2);
		read_reg3 = Xil_In32(AD3);
		read_reg4 = Xil_In32(AD4);
		//read_reg5 = Xil_In32(AD5);
		//read_reg6 = Xil_In32(AD6);
		//read_reg7 = Xil_In32(AD7);
		//read_reg8 = Xil_In32(AD8);
		//read_reg9 = Xil_In32(AD9);
		/*
		 read_reg10 = Xil_In32(AD10);
		 read_reg11 = Xil_In32(AD11);
		 read_reg12 = Xil_In32(AD12);
		 read_reg13 = Xil_In32(AD13);
		 read_reg14 = Xil_In32(AD14);
		 read_reg15 = Xil_In32(AD15);
		 read_reg16 = Xil_In32(AD16);
		 read_reg17 = Xil_In32(AD17);
		 read_reg18 = Xil_In32(AD18);
		 read_reg19 = Xil_In32(AD19);

		 read_reg20 = Xil_In32(AD20);
		 read_reg21 = Xil_In32(AD21);
		 read_reg22 = Xil_In32(AD22);
		 read_reg23 = Xil_In32(AD23);
		 read_reg24 = Xil_In32(AD24);
		 read_reg25 = Xil_In32(AD25);
		 read_reg26 = Xil_In32(AD26);
		 read_reg27 = Xil_In32(AD27);
		 read_reg28 = Xil_In32(AD28);
		 read_reg29 = Xil_In32(AD29);

		 read_reg30 = Xil_In32(AD30);
		 read_reg31 = Xil_In32(AD31);
		 read_reg32 = Xil_In32(AD32);
		 read_reg33 = Xil_In32(AD33);
		 read_reg34 = Xil_In32(AD34);
		 read_reg35 = Xil_In32(AD35);
		 read_reg36 = Xil_In32(AD36);
		 read_reg37 = Xil_In32(AD37);
		 read_reg38 = Xil_In32(AD38);
		 read_reg39 = Xil_In32(AD39);

		 read_reg40 = Xil_In32(AD40);
		 read_reg41 = Xil_In32(AD41);
		 read_reg42 = Xil_In32(AD42);
		 read_reg43 = Xil_In32(AD43);
		 read_reg44 = Xil_In32(AD44);
		 read_reg45 = Xil_In32(AD45);
		 read_reg46 = Xil_In32(AD46);
		 read_reg47 = Xil_In32(AD47);
		 read_reg48 = Xil_In32(AD48);
		 read_reg49 = Xil_In32(AD49);

		 read_reg50 = Xil_In32(AD50);
		 read_reg51 = Xil_In32(AD51);
		 read_reg52 = Xil_In32(AD52);
		 read_reg53 = Xil_In32(AD53);
		 read_reg54 = Xil_In32(AD54);
		 read_reg55 = Xil_In32(AD55);
		 read_reg56 = Xil_In32(AD56);
		 read_reg57 = Xil_In32(AD57);
		 read_reg58 = Xil_In32(AD58);
		 read_reg59 = Xil_In32(AD59);

		 read_reg60 = Xil_In32(AD60);
		 read_reg61 = Xil_In32(AD61);
		 read_reg62 = Xil_In32(AD62);
		 read_reg63 = Xil_In32(AD63);
		 */
		//} else {
		//	xil_printf("%x\n", (unsigned long) read_reg0);
		//}
	}

	return 0;
}
