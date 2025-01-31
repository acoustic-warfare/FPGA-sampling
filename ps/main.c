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

int main() {
  Xuint32 *slaveaddr_p = (Xuint32 *)0x43C00000;  // AXI_slave start addr

  u32 reg_data_out = *(slaveaddr_p + 1);

  // set number of arrays used based on switches
  u32 nr_arrays = ((reg_data_out >> 3) & 0x3);  // Nr of arrays
  xil_printf("Nr of arrays: %x\r\n", nr_arrays);

  // set number of 32bit slots in payload_header
  u32 payload_header_size = 2;

  // constants that will be sent in payload_header
  u32 protocol_ver = 3;
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

  u16_t Port = 21875;

  // 1458 bytes is max that can fit in a udp frame from the zynq
  int buflen = (payload_header_size + nr_arrays * 64) * 4;  // 1458;

  /* The MAC address of the board. This should be unique per board */
  unsigned char mac_ethernet_address[] = {0x00, 0x00, 0x00, 0x01, 0x00, 0x00};

  netif = &server_netif;

  init_platform();

  xil_printf("\r\n\r\n");
  xil_printf("-----lwIP RAW Mode Application ------\r\n");

  /* initliaze IP addresses to be used */
#if (LWIP_DHCP == 1 || LWIP_DHCP == 0)
  IP4_ADDR(&ipaddr, 192, 168, 1, 75);  // Init/default IP address
  IP4_ADDR(&netmask, 0, 0, 0, 0);
  IP4_ADDR(&gw, 192, 168, 1, 1);

  print_ip_settings(&ipaddr, &netmask, &gw);
#endif

  u32 sys_id = (reg_data_out >> 1) & 0x3;  // ID of FPGA
  xil_printf("System ID: %x\r\n", sys_id);

  // Sets ipaddr based on the system id
  switch (sys_id) {
    case 0:
      IP4_ADDR(&ipaddr, 192, 168, 1, 75);
      Port = 21875;
      break;
    case 1:
      IP4_ADDR(&ipaddr, 192, 168, 1, 76);
      Port = 21876;
      break;
    case 2:
      IP4_ADDR(&ipaddr, 192, 168, 1, 77);
      Port = 21877;
      break;
    case 3:
      IP4_ADDR(&ipaddr, 192, 168, 1, 78);
      Port = 21878;
      break;
    default:
      IP4_ADDR(&ipaddr, 192, 168, 1, 75);
      Port = 21875;
      break;
  }

  print_ip_settings(&ipaddr, &netmask, &gw);

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

  // pointer to memory start address where data will be sent 0x10000000
  Xuint32 *data_p = (Xuint32 *)0x10000000;

  // start AXI4 write/read burst transaction (axi_init_pulse)
  *(slaveaddr_p + 0) = 0x00000001;
  *(slaveaddr_p + 0) = 0x00000000;

  // add 32-bit payload_headder
  data[0] = protocol_ver << 24;  // first 8-bits of header: Protocol Version
  data[0] += nr_arrays << 16;    // second 8-bits of header: Number of Arrays
  data[0] += frequency;          // last 16-bits of header: Frequency

  u32 counter = 0;

  while (1) {
    // check if fifo are empty
    empty = *(slaveaddr_p + 3);
    if (empty == 0) {
      data[1] = counter;
      counter++;

      // recive data from AXI
      if (nr_arrays == 1) {
        for (int i = 0; i < 8; i++) {  // mic 0-7 (56-63)
          data[i + payload_header_size + 0] = *(data_p + 56 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 8-15 (55-48)
          data[i + payload_header_size + 8] = *(data_p + 55 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 16-23 (40-47)
          data[i + payload_header_size + 16] = *(data_p + 40 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 24-31 (39-32)
          data[i + payload_header_size + 24] = *(data_p + 39 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 32-39 (24-31)
          data[i + payload_header_size + 32] = *(data_p + 24 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 40-47 (23-16)
          data[i + payload_header_size + 40] = *(data_p + 23 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 48-55 (8-15)
          data[i + payload_header_size + 48] = *(data_p + 8 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 56-63 (7-0)
          data[i + payload_header_size + 56] = *(data_p + 7 - i);
        }
      } else if (nr_arrays == 2) {
        // ARRAY 2
        for (int i = 0; i < 8; i++) {  // mic 0-7 (120-127)
          data[i + payload_header_size + 0] = *(data_p + 120 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 8-15 (119-112)
          data[i + payload_header_size + 8] = *(data_p + 119 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 16-23 (104-111)
          data[i + payload_header_size + 16] = *(data_p + 104 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 24-31 (103-96)
          data[i + payload_header_size + 24] = *(data_p + 103 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 32-39 (88-95)
          data[i + payload_header_size + 32] = *(data_p + 88 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 40-47 (87-80)
          data[i + payload_header_size + 40] = *(data_p + 87 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 48-55 (72-79)
          data[i + payload_header_size + 48] = *(data_p + 72 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 56-63 (71-64)
          data[i + payload_header_size + 56] = *(data_p + 71 - i);
        }

        // ARRAY 1
        for (int i = 0; i < 8; i++) {  // mic 64-71 (56-63)
          data[i + payload_header_size + 64] = *(data_p + 56 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 72-79 (55-48)
          data[i + payload_header_size + 72] = *(data_p + 55 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 80-87 (40-47)
          data[i + payload_header_size + 80] = *(data_p + 40 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 88-95 (39-32)
          data[i + payload_header_size + 88] = *(data_p + 39 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 96-103 (24-31)
          data[i + payload_header_size + 96] = *(data_p + 24 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 104-111 (23-16)
          data[i + payload_header_size + 104] = *(data_p + 23 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 112-119 (8-15)
          data[i + payload_header_size + 112] = *(data_p + 8 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 120-127 (7-0)
          data[i + payload_header_size + 120] = *(data_p + 7 - i);
        }
      } else if (nr_arrays == 3) {
        // ARRAY 3
        for (int i = 0; i < 8; i++) {  // mic 0-7 (184-191)
          data[i + payload_header_size + 0] = *(data_p + 184 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 8-15 (183-176)
          data[i + payload_header_size + 8] = *(data_p + 183 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 16-23 (168-175)
          data[i + payload_header_size + 16] = *(data_p + 168 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 24-31 (167-160)
          data[i + payload_header_size + 24] = *(data_p + 167 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 32-39 (152-159)
          data[i + payload_header_size + 32] = *(data_p + 152 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 40-47 (151-144)
          data[i + payload_header_size + 40] = *(data_p + 151 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 48-55 (136-143)
          data[i + payload_header_size + 48] = *(data_p + 136 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 56-63 (135-128)
          data[i + payload_header_size + 56] = *(data_p + 135 - i);
        }

        // ARRAY 2
        for (int i = 0; i < 8; i++) {  // mic 64-71 (120-127)
          data[i + payload_header_size + 64] = *(data_p + 120 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 72-79 (119-112)
          data[i + payload_header_size + 72] = *(data_p + 119 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 80-87 (104-111)
          data[i + payload_header_size + 80] = *(data_p + 104 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 88-95 (103-96)
          data[i + payload_header_size + 88] = *(data_p + 103 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 96-103 (88-95)
          data[i + payload_header_size + 96] = *(data_p + 88 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 104-111 (87-80)
          data[i + payload_header_size + 104] = *(data_p + 87 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 112-119 (72-79)
          data[i + payload_header_size + 112] = *(data_p + 72 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 120-127 (71-64)
          data[i + payload_header_size + 120] = *(data_p + 71 - i);
        }

        // ARRAY 1
        for (int i = 0; i < 8; i++) {  // mic 128-135 (56-63)
          data[i + payload_header_size + 128] = *(data_p + 56 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 136-143 (55-48)
          data[i + payload_header_size + 136] = *(data_p + 55 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 144-151 (40-47)
          data[i + payload_header_size + 144] = *(data_p + 40 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 152-159 (39-32)
          data[i + payload_header_size + 152] = *(data_p + 39 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 160-167 (24-31)
          data[i + payload_header_size + 160] = *(data_p + 24 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 168-175 (23-16)
          data[i + payload_header_size + 168] = *(data_p + 23 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 176-183 (8-15)
          data[i + payload_header_size + 176] = *(data_p + 8 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 184-191 (7-0)
          data[i + payload_header_size + 184] = *(data_p + 7 - i);
        }
      } else if (nr_arrays == 4) {
        // ARRAY 4
        for (int i = 0; i < 8; i++) {  // mic 0-7 (248-255)
          data[i + payload_header_size + 0] = *(data_p + 248 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 8-15 (247-240)
          data[i + payload_header_size + 8] = *(data_p + 247 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 16-23 (232-239)
          data[i + payload_header_size + 16] = *(data_p + 232 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 24-31 (231-224)
          data[i + payload_header_size + 24] = *(data_p + 231 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 32-39 (216-223)
          data[i + payload_header_size + 32] = *(data_p + 216 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 40-47 (215-208)
          data[i + payload_header_size + 40] = *(data_p + 215 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 48-55 (200-207)
          data[i + payload_header_size + 48] = *(data_p + 200 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 56-63 (199-192)
          data[i + payload_header_size + 56] = *(data_p + 199 - i);
        }

        // ARRAY 3
        for (int i = 0; i < 8; i++) {  // mic 64-71 (184-191)
          data[i + payload_header_size + 64] = *(data_p + 184 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 72-79 (183-176)
          data[i + payload_header_size + 72] = *(data_p + 183 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 80-87 (168-175)
          data[i + payload_header_size + 80] = *(data_p + 168 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 88-95 (167-160)
          data[i + payload_header_size + 88] = *(data_p + 167 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 96-103 (152-159)
          data[i + payload_header_size + 96] = *(data_p + 152 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 104-111 (151-144)
          data[i + payload_header_size + 104] = *(data_p + 151 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 112-119 (136-143)
          data[i + payload_header_size + 112] = *(data_p + 136 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 120-127 (135-128)
          data[i + payload_header_size + 120] = *(data_p + 135 - i);
        }

        // ARRAY 2
        for (int i = 0; i < 8; i++) {  // mic 128-135 (120-127)
          data[i + payload_header_size + 128] = *(data_p + 120 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 136-143 (119-112)
          data[i + payload_header_size + 136] = *(data_p + 119 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 144-151 (104-111)
          data[i + payload_header_size + 144] = *(data_p + 104 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 152-159 (103-96)
          data[i + payload_header_size + 152] = *(data_p + 103 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 160-167 (88-95)
          data[i + payload_header_size + 160] = *(data_p + 88 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 168-175 (87-80)
          data[i + payload_header_size + 168] = *(data_p + 87 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 176-183 (72-79)
          data[i + payload_header_size + 176] = *(data_p + 72 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 184-191 (71-64)
          data[i + payload_header_size + 184] = *(data_p + 71 - i);
        }

        // ARRAY 1
        for (int i = 0; i < 8; i++) {  // mic 192-199 (56-63)
          data[i + payload_header_size + 192] = *(data_p + 56 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 200-207 (55-48)
          data[i + payload_header_size + 200] = *(data_p + 55 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 208-215 (40-47)
          data[i + payload_header_size + 208] = *(data_p + 40 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 216-223 (39-32)
          data[i + payload_header_size + 216] = *(data_p + 39 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 224-231 (24-31)
          data[i + payload_header_size + 224] = *(data_p + 24 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 232-239 (23-16)
          data[i + payload_header_size + 232] = *(data_p + 23 - i);
        }
        for (int i = 0; i < 8; i++) {  // mic 240-247 (8-15)
          data[i + payload_header_size + 240] = *(data_p + 8 + i);
        }
        for (int i = 0; i < 8; i++) {  // mic 248-255 (7-0)
          data[i + payload_header_size + 248] = *(data_p + 7 - i);
        }
      }

      // flush the cache from old data
      Xil_DCacheFlushRange(data_p, 2048);  // 256*4*
      // send read_done to AXI (read_done_pulse)
      *(slaveaddr_p + 0) = 0x00000002;
      *(slaveaddr_p + 0) = 0x00000000;

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
