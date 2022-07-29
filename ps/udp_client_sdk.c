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

/*
 void delay(unsigned int mseconds){
 clock_t goal = mseconds \+ clock();
 while (goal > clock());
 }
 */

void print_ip(char *msg, struct ip_addr *ip)
{
   print(msg);
   xil_printf("%d.%d.%d.%d\r\n", ip4_addr1(ip), ip4_addr2(ip), ip4_addr3(ip),
              ip4_addr4(ip));
}

void print_ip_settings(struct ip_addr *ip, struct ip_addr *mask,
                       struct ip_addr *gw)
{

   print_ip("Board IP: ", ip);
   print_ip("Netmask : ", mask);
   print_ip("Gateway : ", gw);
}

void PayloadID(u32 data[])
{
}

int main()
{

   u32 read_reg64;
   u32 read_reg65;

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
       {0x00, 0x00, 0x00, 0x01, 0x00, 0x00};

   // before sending to network

   u32 data[124];

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
                  PLATFORM_EMAC_BASEADDR))
   {
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

   while (((netif->ip_addr.addr) == 0) && (dhcp_timoutcntr > 0))
   {

      xemacif_input(netif);

      if (TcpFastTmrFlag)
      {
         tcp_fasttmr();
         TcpFastTmrFlag = 0;
      }

      if (TcpSlowTmrFlag)
      {
         tcp_slowtmr();
         TcpSlowTmrFlag = 0;
      }
   }

   if (dhcp_timoutcntr <= 0)
   {
      if ((netif->ip_addr.addr) == 0)
      {
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

   IP4_ADDR(&ip_remote, 192, 168, 1, 3); // windows pc

   udp_1 = udp_new();

   error = udp_bind(udp_1, IP_ADDR_ANY, Port);

   if (error != 0)
   {
      xil_printf("Failed %d\r\n", error);
   }

   else if (error == 0)
   {
      xil_printf("Success in UDP binding \r\n");
   }

   error = udp_connect(udp_1, &ip_remote, Port);

   if (error != 0)
   {
      xil_printf("Failed %d\r\n", error);
   }

   else if (error == 0)
   {
      xil_printf("Success in UDP connect \r\n");
   }

   while (1)
   {

      read_reg64 = Xil_In32(AD64);
      read_reg65 = Xil_In32(AD65);
      if (read_reg64 == 0 && read_reg65 == 0)
      {

         data[0] = Xil_In32(AD0);
         data[1] = Xil_In32(AD1);
         data[2] = Xil_In32(AD2);
         data[3] = Xil_In32(AD3);
         data[4] = Xil_In32(AD4);
         data[5] = Xil_In32(AD5);
         data[6] = Xil_In32(AD6);
         data[7] = Xil_In32(AD7);
         data[8] = Xil_In32(AD8);
         data[9] = Xil_In32(AD9);

         data[10] = Xil_In32(AD10);
         data[11] = Xil_In32(AD11);
         data[12] = Xil_In32(AD12);
         data[13] = Xil_In32(AD13);
         data[14] = Xil_In32(AD14);
         data[15] = Xil_In32(AD15);
         data[16] = Xil_In32(AD16);
         data[17] = Xil_In32(AD17);
         data[18] = Xil_In32(AD18);
         data[19] = Xil_In32(AD19);

         data[20] = Xil_In32(AD20);
         data[21] = Xil_In32(AD21);
         data[22] = Xil_In32(AD22);
         data[23] = Xil_In32(AD23);
         data[24] = Xil_In32(AD24);
         data[25] = Xil_In32(AD25);
         data[26] = Xil_In32(AD26);
         data[27] = Xil_In32(AD27);
         data[28] = Xil_In32(AD28);
         data[29] = Xil_In32(AD29);

         data[30] = Xil_In32(AD30);
         data[31] = Xil_In32(AD31);
         data[32] = Xil_In32(AD32);
         data[33] = Xil_In32(AD33);
         data[34] = Xil_In32(AD34);
         data[35] = Xil_In32(AD35);
         data[36] = Xil_In32(AD36);
         data[37] = Xil_In32(AD37);
         data[38] = Xil_In32(AD38);
         data[39] = Xil_In32(AD39);

         data[40] = Xil_In32(AD40);
         data[41] = Xil_In32(AD41);
         data[42] = Xil_In32(AD42);
         data[43] = Xil_In32(AD43);
         data[44] = Xil_In32(AD44);
         data[45] = Xil_In32(AD45);
         data[46] = Xil_In32(AD46);
         data[47] = Xil_In32(AD47);
         data[48] = Xil_In32(AD48);
         data[49] = Xil_In32(AD49);

         data[50] = Xil_In32(AD50);
         data[51] = Xil_In32(AD51);
         data[52] = Xil_In32(AD52);
         data[53] = Xil_In32(AD53);
         data[54] = Xil_In32(AD54);
         data[55] = Xil_In32(AD55);
         data[56] = Xil_In32(AD56);
         data[57] = Xil_In32(AD57);
         data[58] = Xil_In32(AD58);
         data[59] = Xil_In32(AD59);

         data[60] = Xil_In32(AD60);
         data[61] = Xil_In32(AD61);
         data[62] = Xil_In32(AD62);
         data[63] = Xil_In32(AD63);

         xemacif_input(netif);

         p = pbuf_alloc(PBUF_TRANSPORT, buflen, PBUF_POOL);

         if (!p)
         {
            xil_printf("error allocating pbuf \r\n");
            return ERR_MEM;
         }

         // PayloadID(data);

         memcpy(p->payload, data, buflen);

         udp_send(udp_1, p);

         pbuf_free(p);
      }
   }
}
