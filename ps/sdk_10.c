//DEFINE STATEMENTS TO INCREASE SPEED
#undef LWIP_TCP
#undef LWIP_DHCP
#include <stdio.h>
#include "xparameters.h"
#include "netif/xadapter.h"
#include "platform.h"
#include "platform_config.h"
#if defined (__arm__) || defined(__aarch64__)
#include "xil_printf.h"
#endif
#include "lwip/udp.h"
#include "xil_cache.h"
#include "xil_io.h"

#define AD0 0x40000000
#define AD1 0x40000004

#define AD64 0x40000100
#define AD65 0x40000104

/* defined by each RAW mode application */
void print_app_header();
int start_application();
//int transfer_data();
void tcp_fasttmr(void);
void tcp_slowtmr(void);
/* missing declaration in lwIP */
void lwip_init();

extern volatile int TcpFastTmrFlag;
extern volatile int TcpSlowTmrFlag;
/* set up netif stuctures */
static struct netif server_netif;
struct netif *echo_netif;

// Global Variables to store results and handle data flow
int Centroid;

// Global variables for data flow
volatile u8 IndArrDone;
volatile u32 EthBytesReceived;
volatile u8 SendResults;
volatile u8 DMA_TX_Busy;
volatile u8 Error;

// Global Variables for Ethernet handling
u16_t RemotePort = 21844;
struct ip_addr RemoteAddr;
struct udp_pcb send_pcb;

void print_ip(char *msg, struct ip_addr *ip) {
	print(msg);
	xil_printf("%d.%d.%d.%d\n\r", ip4_addr1(ip), ip4_addr2(ip), ip4_addr3(ip),
			ip4_addr4(ip));
}

void print_ip_settings(struct ip_addr *ip, struct ip_addr *mask,
		struct ip_addr *gw) {

	print_ip("Board IP: ", ip);
	print_ip("Netmask : ", mask);
	print_ip("Gateway : ", gw);
}

/* print_app_header: function to print a header at start time */

int main() {

	u32 zeros = 0x0;
	u32 ones = 0Xffffffff;
	u32 array[15];
	int counter = 0;
   
	//u32 numbers[10]={0x00000000,0x00000001,0x00000002,0x00000003,0x00000004,0x00000005,0x00000006,0x00000007,0x00000008,0x00000009};
	u32 read_reg0;
	u32 read_reg64;
	u32 read_reg65;

	////////////////////////////////////////////////////////////////////////////////// BELOW IS UDP CODE
	struct ip_addr ipaddr, netmask, gw /*, Remotenetmask, Remotegw*/;
	struct pbuf * psnd;
	err_t udpsenderr;
	int status = 0;

	/* the mac address of the board. this should be unique per board */
	unsigned char mac_ethernet_address[] =
			{ 0x00, 0x0a, 0x35, 0x00, 0x01, 0x10 };
	/* Use the same structure for the server and the echo server */
	echo_netif = &server_netif;
	init_platform();

	/* initialize IP addresses to be used */
	IP4_ADDR(&ipaddr, 192, 168, 1, 10);
	IP4_ADDR(&netmask, 255, 255, 255, 0);
	//IP4_ADDR(&gw, 0, 0, 0, 0);

	IP4_ADDR(&RemoteAddr, 192, 168, 1, 2);
	//IP4_ADDR(&Remotenetmask, 255, 255, 255,  0);
	//IP4_ADDR(&Remotegw,      10, 0,   0,  1);

	/* Initialize the lwip for UDP */
	lwip_init();

	/* Add network interface to the netif_list, and set it as default */
	if (!xemac_add(echo_netif, &ipaddr, &netmask, &gw, mac_ethernet_address, /////////////////////////////////////////////////////////////////
	PLATFORM_EMAC_BASEADDR)) {
		xil_printf("Error adding N/W interface\n\r");
		return -1;
	}
	netif_set_default(echo_netif);   ////////////////////////////////////////////////////////////////////////

	/* now enable interrupts */
	platform_enable_interrupts();

	/* specify that the network if is up */
	netif_set_up(echo_netif);  ////////////////////////////////////////////////////////////////////////////////////

	xil_printf("Zyboboard IP settings: \r\n");  
	print_ip_settings(&ipaddr, &netmask, &gw);
	xil_printf("Remote IP settings: \r\n");
	//print_ip_settings(&RemoteAddr, &Remotenetmask, &Remotegw);
	print_ip("Board IP: ", &RemoteAddr);

	/* start the application (web server, rxtest, txtest, etc..) */
	//status = start_application();
	if (status != 0) {
		xil_printf("Error in start_application() with code: %d\n\r", status);
		goto ErrorOrDone;
	}

	/* receive and process packets */
	while (Error == 0) {

		if (TcpFastTmrFlag) {
			tcp_fasttmr();  ///////////////////////////////////////////////
			TcpFastTmrFlag = 0;
			//SendResults = 1;
			//xil_printf("*");
		}
		if (TcpSlowTmrFlag) {
			tcp_slowtmr();    /////////////////////////////////////////////////
			TcpSlowTmrFlag = 0;
			SendResults = 1;
		}
		//xemacif_input(echo_netif);
		//transfer_data();

		/* Receive packets */
		xemacif_input(echo_netif);  ////////////////////////////////////////

		read_reg64 = Xil_In32(AD64);
		read_reg65 = Xil_In32(AD65);

		if (read_reg64 == 0 && read_reg65 == 0) {
			///////////////////////////////////////////////////////////////////// my test code

			read_reg0 = Xil_In32(AD0);
			Xil_In32(AD1);
			array[counter] = read_reg0;

			//else {
			//	array[counter] = ones;
			//}

			counter = counter + 1;
         

			//SendResults == 1 &&
			/* Send results back from time to time */
			if (counter == 10) {

				counter = 0;
				SendResults = 0;
				// Read the results from the FPGA
				//Centroid = "DEEDBEEF";

				// Send out the centroid result over UDP
				psnd = pbuf_alloc(PBUF_TRANSPORT, sizeof(array), PBUF_REF);
				psnd->payload = &array;
				udpsenderr = udp_sendto(&send_pcb, psnd, &RemoteAddr,
						RemotePort);
				//xil_printf(" %d \n", array[0] );
				if (udpsenderr != ERR_OK) {
					xil_printf("UDP Send failed with Error %d\n\r", udpsenderr);
					goto ErrorOrDone;
				}
				pbuf_free(psnd);
			}
		}
	}
	// Jump point for failure
	ErrorOrDone: xil_printf(
			"Catastrophic Error! Shutting down and exiting...\n\r");

	cleanup_platform();
	return 0;
}
