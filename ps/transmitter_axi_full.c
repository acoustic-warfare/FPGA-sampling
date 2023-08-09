#include <stdio.h>

#include "lwip/udp.h"
#include "lwipopts.h"
#include "netif/xadapter.h"
#include "platform.h"
#include "platform_config.h"
#include "xbasic_types.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xparameters.h"

void platform_enable_interrupts();
void lwip_init(void);

void Xil_DCacheFlush(void);
void Xil_DCacheFlushRange(u32 *adr, u32 len);

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
    u32 nr_arrays = 4;

    // set number of 32bit slots in payload_header
    u32 payload_header_size = 2;

    // constants that will be sent in payload_header
    u32 protocol_ver = 2;

    u32 frequency = 48828;

    u32 data[payload_header_size + nr_arrays * 64];

    u32 empty;

    struct netif *netif, server_netif;   // Network structure define
    struct ip_addr ipaddr, netmask, gw;  // DHCP Settings
    // Creation of a basic UDP Packet

    err_t error;

    struct ip_addr ip_remote;
    struct udp_pcb *udp_1;
    struct pbuf *p;

    u16_t Port = 21844;

    // 1458 bytse is max that can fit in a udp frame from the zynq (probebly some unknown overhead)
    int buflen = 1458;

    /* The MAC address of the board. this should be unique per board */
    unsigned char mac_ethernet_address[] = {0x00, 0x00, 0x00, 0x01, 0x00, 0x00};

    netif = &server_netif;

    init_platform();

    xil_printf("\r\n\r\n");
    xil_printf("-----lwIP RAW Mode Application ------\r\n");

    /* initliaze IP addresses to be used */
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

    // ip of receiving pc
    IP4_ADDR(&ip_remote, 10, 0, 0, 1);

    udp_1 = udp_new();

    error = udp_bind(udp_1, IP_ADDR_ANY, Port);
    if (error != 0) {
        xil_printf("Failed %d\r\n", error);
    } else if (error == 0) {
        xil_printf("Success in UDP binding \r\n");
    }

    error = udp_connect(udp_1, &ip_remote, Port);
    if (error != 0) {
        xil_printf("Failed %d\r\n", error);
    } else if (error == 0) {
        xil_printf("Success in UDP connect \r\n");
    }

    xil_printf("\r\n");
    xil_printf("----------Acoustic-Warfare Sending UDP!----------\r\n");
    xil_printf("-------------Bursts using AXI_FULL!--------------\r\n");
    xil_printf("\r\n");

    Xil_DCacheFlush();  // important to make the zynq not cache the data
    // Xil_L2CacheDisable();

    // pointer to address the AXI4-Lite slave
    Xuint32 *slaveaddr_p = (Xuint32 *)0x43C00000;  // AXI_slave start addr

    // pointer to memory start address where data will be sent 0x10000000
    Xuint32 *data_p = (Xuint32 *)0x10000000;

    // start AXI4 write/read burst transaction (axi_init_pulse)
    *(slaveaddr_p + 0) = 0x00000001;
    *(slaveaddr_p + 0) = 0x00000000;

    // add 32-bit payload_headder
    data[0] = protocol_ver << 24;  // first 8-bits of header: Protocol Version
    data[0] += nr_arrays << 16;    // second 8-bits of header: Number of Arrays
    data[0] += frequency;          // last 16-bits of header: Frequency

    while (1) {
        // check if fifo are empty
        empty = *(slaveaddr_p + 3);
        if (empty == 0) {
            // flush the cache from old data
            Xil_DCacheFlushRange(data_p, 2048);

            // send read_done to AXI (read_done_pulse)
            *(slaveaddr_p + 0) = 0x00000002;
            *(slaveaddr_p + 0) = 0x00000000;

            // recive data from AXI
            data[1] = 100;  // FIX sample counter

            for (int i = 0; i < 256; i++) {
                data[i + payload_header_size] = *(data_p + i);
            }

            // package and send UDP
            xemacif_input(netif);
            p = pbuf_alloc(PBUF_TRANSPORT, buflen, PBUF_POOL);
            memcpy(p->payload, data, buflen);
            udp_send(udp_1, p);
            pbuf_free(p);
        }
    }

    cleanup_platform();
    return 0;
}
