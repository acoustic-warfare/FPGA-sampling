#include <stdio.h>
#include <string.h>

#include "lwip/udp.h"
#include "lwipopts.h"
#include "netif/xadapter.h"
#include "platform.h"
#include "platform_config.h"
#include "xil_io.h"
#include "xparameters.h"

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

#define AD0 0x40000000

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

void PayloadID(u32 data[]) {}

int main() {
    // set number of arrays used
    u32 nr_arrays = 2;

    // set number of 32bit slots in payload_header
    u32 payload_header_size = 4;

    // constants that will be sent in payload_header
    u32 array_id = 1;
    u32 protocol_ver = 1;
    u32 samp_frequency = 48828;

    u32 data[payload_header_size + nr_arrays * 64];

    u32 start_addr = AD0;

    u32 empty;

    struct netif *netif, server_netif;   // Network structure define
    struct ip_addr ipaddr, netmask, gw;  // DHCP Settings
    // Creation of a basic UDP Packet

    err_t error;

    struct ip_addr ip_remote;
    struct udp_pcb *udp_1;
    struct pbuf *p;

    u16_t Port = 21844;

    int buflen = 500;

    /* The MAC address of the board. this should be unique per board */

    unsigned char mac_ethernet_address[] = {0x00, 0x00, 0x00, 0x01, 0x00, 0x00};

    // before sending to network

    int len = 0;

    len = sizeof(data);

    data[len] = data[len];

    netif = &server_netif;

    init_platform();

    xil_printf("\r\n\r\n");

    xil_printf("-----lwIP RAW Mode Application ------\r\n");

    /* initliaze IP addresses to be used */

#if (LWIP_DHCP == 0)
    IP4_ADDR(&ipaddr, 192, 168, 1, 75);
    IP4_ADDR(&netmask, 0, 0, 0, 0);
    IP4_ADDR(&gw, 192, 168, 1, 1);

    print_ip_settings(&ipaddr, &netmask, &gw);
#endif

#if (LWIP_DHCP == 1 || LWIP_DHCP == 0)
    IP4_ADDR(&ipaddr, 192, 168, 1, 75);
    IP4_ADDR(&netmask, 0, 0, 0, 0);
    IP4_ADDR(&gw, 192, 168, 1, 1);

    print_ip_settings(&ipaddr, &netmask, &gw);
#endif

    lwip_init();

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

    xil_printf("Setup Done!\r\n");

    // ip of reciving pc
	IP4_ADDR(&ip_remote, 10, 0, 0, 1);

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

    xil_printf("\r\n");
    xil_printf("----------Acoustic-Warfare Sending UDP!----------\r\n");

    data[0] = array_id;
    data[1] = protocol_ver;
    data[2] = samp_frequency;

    while (1) {
         //ADDR: (data)start_addr-start_addr+63*4     (rd_enable)start_addr+64*4       (counter)start_addr+65*4

        empty = Xil_In32(start_addr + nr_arrays * 64 * 4);
        if (empty == 0) {
            // add payload_headder

            data[3] = Xil_In32(start_addr + nr_arrays * 64 * 4 + 4); //counter

            for (int i = 0; i < 64*nr_arrays; i++) {
                data[payload_header_size + i] = Xil_In32(start_addr + 4 * i);
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
