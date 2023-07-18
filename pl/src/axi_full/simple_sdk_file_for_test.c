#include "platform.h"
#include "platform_config.h"

#include "platform_config.h"
#include "xparameters.h"
#include "xil_printf.h"
#include "xbasic_types.h"

#include "xil_io.h"


int main() {

    init_platform();
    Xil_DCacheDisable();
    xil_printf("== burst test== \n\r");

    // pointer to address the AXI4-Lite slave
    Xuint32 *slaveaddr_p = (Xuint32 *) 0x43C00000; // change this to XPAR_name_of_axi_slave_AXI_BASEADDR
    // pointer to memory address 0x10000000
    Xuint32 *data_p = (Xuint32 *) 0x10000000;

    // check status
    xil_printf("INIT_TXN\t0x%08x\n", *(slaveaddr_p+0));
    xil_printf("TXN_DONE\t0x%08x\n", *(slaveaddr_p+1));
    xil_printf("ERROR\t\t0x%08x\n", *(slaveaddr_p+2));
    xil_printf("\n\r");


    // start AXI4 write/read burst transaction
    Xil_Out32((int)(slaveaddr_p+0),0x00000001);

    xil_printf("INIT_TXN\t0x%08x\n", *(slaveaddr_p+0));
    xil_printf("TXN_DONE\t0x%08x\n", *(slaveaddr_p+1));
    xil_printf("ERROR\t\t0x%08x\n", *(slaveaddr_p+2));
    xil_printf("\n\r");

    Xil_Out32((int)(slaveaddr_p+0),0x00000000);



    while(1){
    	for(int i = 0; i < 128; i++) {
           xil_printf("DATA+%d\t\t0x%08x\n", i, *(data_p+i));
    	}
        Xil_Out32((int)(slaveaddr_p+0),0x00000002);
        Xil_Out32((int)(slaveaddr_p+0),0x00000000);
    }


    cleanup_platform();
    return 0;
}
