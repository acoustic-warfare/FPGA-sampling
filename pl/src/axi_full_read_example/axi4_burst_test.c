#include "platform.h"
#include "xil_printf.h"
#include "xbasic_types.h"
#include "xparameters.h"

int main() {

    init_platform();

    xil_printf("== burst test== \n\r");

    // pointer to address the AXI4-Lite slave
    volatile Xuint32 *slaveaddr_p = (Xuint32 *) XPAR_AXI4_MASTER_BURST_0_S00_AXI_BASEADDR;

    // pointer to memory address 0x10000000
    volatile Xuint32 *data_p = (Xuint32 *) 0x10000000;

    // check status
    xil_printf("INIT_TXN\t0x%08x\n\r", *(slaveaddr_p+0));
    xil_printf("TXN_DONE\t0x%08x\n\r", *(slaveaddr_p+1));
    xil_printf("ERROR\t\t0x%08x\n\r", *(slaveaddr_p+2));
    xil_printf("\n\r");

    // start AXI4 write/read burst transaction
    *(slaveaddr_p+0) = 0x00000001;
    *(slaveaddr_p+0) = 0x00000000;

    // check status
    xil_printf("INIT_TXN\t0x%08x\n\r", *(slaveaddr_p+0));
    xil_printf("TXN_DONE\t0x%08x\n\r", *(slaveaddr_p+1));
    xil_printf("ERROR\t\t0x%08x\n\r", *(slaveaddr_p+2));
    xil_printf("\n\r");

    // print memory content
    int i;
    for(i = 0; i < 1060; i++) {
        xil_printf("DATA+%d\t\t0x%08x\n\r", i, *(data_p+i));
    }

    cleanup_platform();
    return 0;
}