#include <stdio.h>

#include "xparameters.h"
#if defined (__arm__) || defined(__aarch64__)
#include "xil_printf.h"
#endif

#ifdef XPS_BOARD_ZCU102
#ifdef XPAR_XIICPS_0_DEVICE_ID
#include "xiicps.h"

#define BUF_LEN		10U

#define IOEXPANDER1_ADDR		0x20U

#define IIC_SCLK_RATE_IOEXP		400000

#define CMD_CFG_0_REG		0x06U
#define CMD_OUTPUT_0_REG	0x02U
#define DATA_OUTPUT			0x0U

#define DATA_COMMON_CFG		0xE0U
#define DATA_GT_0000_CFG	0x00U

XIicPs I2c0InstancePtr;

int IicPhyReset(void)
{

	u8 WriteBuffer[BUF_LEN] = {0};
	XIicPs_Config *I2c0CfgPtr;
	int Status = XST_SUCCESS;

	/* Initialize the IIC0 driver so that it is ready to use */
	I2c0CfgPtr = XIicPs_LookupConfig(XPAR_XIICPS_0_DEVICE_ID);
	if (I2c0CfgPtr == NULL) {
		Status = XST_FAILURE;
		return Status;
	}

	Status = XIicPs_CfgInitialize(&I2c0InstancePtr, I2c0CfgPtr,
			I2c0CfgPtr->BaseAddress);
	if (Status != XST_SUCCESS) {
		Status = XST_FAILURE;
		return Status;
	}

	/* Set the IIC serial clock rate */
	XIicPs_SetSClk(&I2c0InstancePtr, IIC_SCLK_RATE_IOEXP);

	/* Configure I/O pins as Output */
	WriteBuffer[0] = CMD_CFG_0_REG;
	WriteBuffer[1] = DATA_OUTPUT;
	Status = XIicPs_MasterSendPolled(&I2c0InstancePtr,
			WriteBuffer, 2, IOEXPANDER1_ADDR);
	if (Status != XST_SUCCESS) {
		Status = XST_FAILURE;
		return Status;
	}

	/* Wait until bus is idle to start another transfer */
	while (XIicPs_BusIsBusy(&I2c0InstancePtr));

	/*
	 * Deasserting I2C_MUX_RESETB
	 * And GEM3 Resetb
	 * Selecting lanes based on configuration
	 */
	WriteBuffer[0] = CMD_OUTPUT_0_REG;
	/* gt0000 or no GT configuration */
	WriteBuffer[1] = DATA_COMMON_CFG | DATA_GT_0000_CFG;

	/* Send the Data */
	Status = XIicPs_MasterSendPolled(&I2c0InstancePtr,
			WriteBuffer, 2, IOEXPANDER1_ADDR);
	if (Status != XST_SUCCESS) {
		Status = XST_FAILURE;
		return Status;
	}

	/* Wait until bus is idle */
	while (XIicPs_BusIsBusy(&I2c0InstancePtr));

	xil_printf("IIC PHY reset on ZCU102 successful \n\r");
}
#endif
#endif
