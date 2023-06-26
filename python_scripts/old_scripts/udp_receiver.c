// Server side implementation of UDP client-server model
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <time.h>

#define PORT 21844
#define MAXLINE 1024

// Driver code
int main(){

   int sockfd;
   int buffer[MAXLINE];

   struct sockaddr_in servaddr, cliaddr;

   // Creating socket file descriptor
   if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0){
      perror("socket creation failed");
      exit(EXIT_FAILURE);
   }

   memset(&servaddr, 0, sizeof(servaddr));
   memset(&cliaddr, 0, sizeof(cliaddr));

   // Filling server information
   servaddr.sin_family = AF_INET; // IPv4
   servaddr.sin_addr.s_addr = INADDR_ANY;
   servaddr.sin_port = htons(PORT);

   // Bind the socket with the server address
   if (bind(sockfd, (const struct sockaddr *)&servaddr, sizeof(servaddr)) < 0){
      perror("bind failed");
      exit(EXIT_FAILURE);
   }

   FILE *fp = fopen("delay_.txt", "w");
   
   time_t secs = 4;               // HOW LONG TIME TO RECORD UDP PACKEGES
   time_t startTime = time(NULL);

   while (time(NULL)-startTime<secs){
      int len, n;

      len = sizeof(cliaddr); // len is value/result

      n = recvfrom(sockfd, (char *)buffer, MAXLINE,
                   MSG_WAITALL, (struct sockaddr *)&cliaddr,
                   &len);
      buffer[n] = '\0';

      // write data in txt file
      for (int i = 0; i < 67; i++){
         fprintf(fp, "%9d, ", buffer[i]);
      }
      fprintf(fp, "%9d\n", buffer[67]);
   }
   
   return 0;
}