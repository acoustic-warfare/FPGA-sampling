// Server side implementation of UDP client-server model
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>

#define PORT 21844
#define MAXLINE 1024
#define MAX_SAMPLES 100000
// Driver code
int main(){

   int sockfd;
   int buffer[MAXLINE];

   struct sockaddr_in servaddr, cliaddr;

   // Creating socket file descriptor
   if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
   {
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
   if (bind(sockfd, (const struct sockaddr *)&servaddr,
            sizeof(servaddr)) < 0)
   {
      perror("bind failed");
      exit(EXIT_FAILURE);
   }

   FILE *fp = fopen("new_sample_data_new.txt", "w");

   
   
   int sample_cnt = 0;
   while (sample_cnt < MAX_SAMPLES)
   {
      int len, n;

      len = sizeof(cliaddr); // len is value/result

      n = recvfrom(sockfd, (char *)buffer, MAXLINE,
                   MSG_WAITALL, (struct sockaddr *)&cliaddr,
                   &len);
      buffer[n] = '\0';

      for (int i = 0; i < 64+63+4; i++)
      {
         fprintf(fp, "%9d, ", buffer[i]);
      }
      fprintf(fp, "%9d\n", buffer[63+4]);
      sample_cnt = sample_cnt +1;
   }
   return 0;
}