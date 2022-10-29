#include <stdio.h>
#include <string.h>
#include "xparameters.h"
#include "netif/xadapter.h"
#include "platform.h"
#include "platform_config.h"
#include "lwip/udp.h"
#include "lwipopts.h"

#include "xil_io.h"

#ifndef __PPC__
#include "xil_printf.h"
#endif

void print_headers();
int start_applications();
int transfer_data();
void platform_enable_interrupts();
void lwip_init(void);
void tcp_fasttmr(void);
void tcp_slowtmr(void);

#if LWIP_DHCP == 1
extern volatile int dhcp_timoutcntr;
err_t dhcp_start(struct netif *netif);
#endif

// extern volatile int TxPerfConnMonCntr;

extern volatile int TcpFastTmrFlag;
extern volatile int TcpSlowTmrFlag;

#define AD0 0x40000000

#define AD64 0x40000100
#define AD65 0x40000104

/*
 void delay(unsigned int mseconds){
 clock_t goal = mseconds \+ clock();
 while (goal > clock());
 }
 */

void print_ip(char *msg, struct ip_addr *ip) {
	print(msg);
	xil_printf("%d.%d.%d.%d\r\n", ip4_addr1(ip), ip4_addr2(ip), ip4_addr3(ip),
			ip4_addr4(ip));
}

void print_ip_settings(struct ip_addr *ip, struct ip_addr *mask,
		struct ip_addr *gw) {

	print_ip("Board IP: ", ip);
	print_ip("Netmask : ", mask);
	print_ip("Gateway : ", gw);
}

void PayloadID(u32 data[]) {
}

int main() {
	// set number of arrays used
	u32 nr_arrays = 1;

	// set number of 32bit slots in payload_header
	u32 payload_header_size = 4;

   // constants that will be sent in payload_header
	u32 array_id = 1;
	u32 protocol_ver = 1;
	u32 samp_frequency = 15625;

	u32 data[payload_header_size + nr_arrays * 64];

	u32 start_addr = AD0;

	u32 empty;

	struct netif *netif, server_netif;  // Network structure define
	struct ip_addr ipaddr, netmask, gw; // DHCP Settings

	// Creation of a basic UDP Packet

	err_t error;

	struct ip_addr ip_remote;
	struct udp_pcb *udp_1;
	struct pbuf *p;

	u16_t Port = 21844;

	int buflen = 500;

	/* The MAC address of the board. this should be unique per board */

	unsigned char mac_ethernet_address[] =
			{ 0x00, 0x00, 0x00, 0x01, 0x00, 0x00 };

	// before sending to network

	int len = 0;

	len = sizeof(data);

	data[len] = data[len];

	netif = &server_netif;

	init_platform();

	xil_printf("\r\n\r\n");

	xil_printf("-----lwIP RAW Mode Demo Application ------\r\n");

	/* initliaze IP addresses to be used */

#if (LWIP_DHCP == 0)
	IP4_ADDR(&ipaddr, 192, 168, 1, 75);
	IP4_ADDR(&netmask, 255, 255, 255, 0);
	IP4_ADDR(&gw, 192, 168, 1, 1);

	print_ip_settings(&ipaddr, &netmask, &gw);
#endif

#if (LWIP_DHCP == 1)
	ipaddr.addr = 0;
	gw.addr = 0;
	netmask.addr = 0;
#endif

	lwip_init();

	/* Add network interface to the netif_list, and set it as default */

	if (!xemac_add(netif, &ipaddr, &netmask, &gw, mac_ethernet_address,
	PLATFORM_EMAC_BASEADDR)) {
		xil_printf("Error adding N/W interface\r\n");
		return -1;
	}

	netif_set_default(netif);

	/* specify that the network if is up */

	netif_set_up(netif);

	/* now enable interrupts */

	platform_enable_interrupts();

#if (LWIP_DHCP == 1)

	/* Create a new DHCP client for this interface.
	 * Note: you must call dhcp_fine_tmr() and dhcp_coarse_tmr() at
	 * the predefined regular intervals after starting the client.
	 */

	dhcp_start(netif);

	dhcp_timoutcntr = 24;

	// TxPerfConnMonCntr = 0;

	while (((netif->ip_addr.addr) == 0) && (dhcp_timoutcntr > 0)) {

		xemacif_input(netif);

		if (TcpFastTmrFlag) {
			tcp_fasttmr();
			TcpFastTmrFlag = 0;
		}

		if (TcpSlowTmrFlag) {
			tcp_slowtmr();
			TcpSlowTmrFlag = 0;
		}
	}

	if (dhcp_timoutcntr <= 0) {
		if ((netif->ip_addr.addr) == 0) {
			xil_printf("DHCP Timeout\r\n");
			xil_printf("Configuring default IP of 192.168.1.75 \r\n");
			IP4_ADDR(&(netif->ip_addr), 192, 168, 1, 75);
			IP4_ADDR(&(netif->netmask), 255, 255, 255, 0);
			IP4_ADDR(&(netif->gw), 192, 168, 1, 1);
		}
	}

	/* receive and process packets */

	print_ip_settings(&(netif->ip_addr), &(netif->netmask), &(netif->gw));

#endif

	/* start the application (web server, rxtest, txtest, etczzz..) */

	xil_printf("Setup Done");

   // ip of reciving pc
	IP4_ADDR(&ip_remote, 192, 168, 1, 2); 

	udp_1 = udp_new();

	error = udp_bind(udp_1, IP_ADDR_ANY, Port);

	if (error != 0) {
		xil_printf("Failed %d\r\n", error);
	}

	else if (error == 0) {
		xil_printf("Success in UDP binding \r\n");
	}

	error = udp_connect(udp_1, &ip_remote, Port);

	if (error != 0) {
		xil_printf("Failed %d\r\n", error);
	}

	else if (error == 0) {
		xil_printf("Success in UDP connect \r\n");
	}

	while (1) {



		empty = Xil_In32(start_addr + nr_arrays * 64 * 4);
		if (empty == 0) {

			// add payload_headder
			data[0] = array_id;
			data[1] = protocol_ver;
			data[2] = samp_frequency;
			data[3] = Xil_In32(start_addr + nr_arrays * 64 * 4 + 8);

			// add payload_data
			// mic 57-63
			for(int i = 0; i < 7; i++){
				data[payload_header_size + i] = Xil_In32(start_addr + 4 * 54 - 4 * i);
			}

			// mic 64
			data[payload_header_size + 7] = Xil_In32(start_addr + 4 * 63);

			// mic 56-49
			for(int i = 0; i < 8; i++){
				data[payload_header_size + 8 + i] = Xil_In32(start_addr + 4 * 55 + 4 * i);
			}

			// mic 41-47
			for(int i = 0; i < 7; i++){
				data[payload_header_size + 16 + i] = Xil_In32(start_addr + 4 * 38 - 4 * i);
			}

			// mic 48
			data[payload_header_size + 23] = Xil_In32(start_addr + 4 * 47);

			// mic 40-33
			for(int i = 0; i < 8; i++){
				data[payload_header_size + 24 + i] = Xil_In32(start_addr + 4 * 39 + 4 * i);
			}

			// mic 25-31
			for(int i = 0; i < 7; i++){
				data[payload_header_size + 32 + i] = Xil_In32(start_addr + 4 * 22 - 4 * i);
			}

			// mic 32
			data[payload_header_size + 39] = Xil_In32(start_addr + 4 * 31);

			// mic 25-17
			for(int i = 0; i < 8; i++){
				data[payload_header_size + 40 + i] = Xil_In32(start_addr + 4 * 23 + 4 * i);
			}

			// mic 9-15
			for(int i = 0; i < 7; i++){
				data[payload_header_size + 48 + i] = Xil_In32(start_addr + 4 * 6 - 4 * i);
			}

			// mic 16
			data[payload_header_size + 55] = Xil_In32(start_addr + 4 * 31);

			// mic 8-1
			for(int i = 0; i < 8; i++){
				data[payload_header_size + 56 + i] = Xil_In32(start_addr + 4 * 7 + 4 * i);
			}


			xemacif_input(netif);

			p = pbuf_alloc(PBUF_TRANSPORT, buflen, PBUF_POOL);

			if (!p) {
				xil_printf("error allocating pbuf \r\n");
				return ERR_MEM;
			}

			memcpy(p->payload, data, buflen);

			udp_send(udp_1, p);

			pbuf_free(p);

		}
	}
}
