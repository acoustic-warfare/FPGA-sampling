// Server side implementation of UDP client-server model 
#include <stdio.h> 
#include <stdlib.h> 
#include <unistd.h> 
#include <string.h> 
#include <sys/types.h> 
#include <sys/socket.h> 
#include <arpa/inet.h> 
#include <netinet/in.h> 
    
#define PORT     21844 
#define MAXLINE 1024 
    
// Driver code 
int main() { 
    
      int sockfd; 
      int buffer[MAXLINE]; 
      
      struct sockaddr_in servaddr, cliaddr; 
         
      // Creating socket file descriptor 
      if ( (sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0 ) { 
         perror("socket creation failed"); 
         exit(EXIT_FAILURE); 
      } 
         
      memset(&servaddr, 0, sizeof(servaddr)); 
      memset(&cliaddr, 0, sizeof(cliaddr)); 
         
      // Filling server information 
      servaddr.sin_family    = AF_INET; // IPv4 
      servaddr.sin_addr.s_addr = INADDR_ANY; 
      servaddr.sin_port = htons(PORT); 
         
      // Bind the socket with the server address 
      if ( bind(sockfd, (const struct sockaddr *)&servaddr,  
               sizeof(servaddr)) < 0 ) 
      { 
         perror("bind failed"); 
         exit(EXIT_FAILURE); 
      } 


      FILE *fp =fopen("tetxc5.txt","w");
      while(1){   
      int len, n; 
      
      len = sizeof(cliaddr);  //len is value/result 
      
      n = recvfrom(sockfd, (char *)buffer, MAXLINE,  
                  MSG_WAITALL, ( struct sockaddr *) &cliaddr, 
                  &len); 
      buffer[n] = '\0'; 


      /*for(int i =0; i<10; i++) {
         if(buffer[i] > 65279){
            buffer[i] = 0;
         }
         
         
         else if (buffer[i] < -65279) {
            buffer[i] = 0;
         }
      }*/
      //printf(" %d \n", buffer[0]); 
      fprintf(fp, "%d \n", buffer[50]);
      //fprintf(fp, "%d \n", buffer[1]);
      //fprintf(fp, "%d \n", buffer[2]);
      //fprintf(fp, "%d \n", buffer[3]);
      //fprintf(fp, "%d \n", buffer[4]);
      //fprintf(fp, "%d \n", buffer[5]);
      //fprintf(fp, "%d \n", buffer[6]);
      //fprintf(fp, "%d \n", buffer[7]);
      //fprintf(fp, "%d \n", buffer[8]);
      //fprintf(fp, "%d \n", buffer[9]);
      

      
    }     
    return 0; 
}