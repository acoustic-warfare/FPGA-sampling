// Server side implementation of UDP client-server model
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#define PORT 21844
#define MAXLINE 2048
#define MAX_SAMPLES 10000
// Driver code
int main() {
    int sockfd;
    int buffer[MAXLINE];

    //unsigned char buffer[1056];

    struct sockaddr_in servaddr, cliaddr;

    // Creating socket file descriptor
    if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
        perror("socket creation failed");
        exit(EXIT_FAILURE);
    }

    memset(&servaddr, 0, sizeof(servaddr));
    memset(&cliaddr, 0, sizeof(cliaddr));

    // Filling server information
    servaddr.sin_family = AF_INET;  // IPv4
    servaddr.sin_addr.s_addr = INADDR_ANY;
    servaddr.sin_port = htons(PORT);

    // Bind the socket with the server address
    if (bind(sockfd, (const struct sockaddr *)&servaddr, sizeof(servaddr)) <
        0) {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }

    FILE *fp = fopen("new_sample_data_new.txt", "w");

    for (int sample_cnt = 0; sample_cnt < MAX_SAMPLES; sample_cnt++) {
        int len, n;

        len = sizeof(cliaddr);  // len is value/result
         
        n = recvfrom(sockfd, buffer, sizeof(buffer), MSG_WAITALL, (struct sockaddr *)&cliaddr, &len);
        //n = recvfrom(sockfd, (char *)buffer, MAXLINE, MSG_WAITALL,(struct sockaddr *)&cliaddr, &len);
        buffer[n] = '\0';

        // header
        fprintf(fp, "arrayId:");
        fprintf(fp, "%1d, ", buffer[0]);

        fprintf(fp, "protocolVer: ");
        fprintf(fp, "%1d, ", buffer[1]);

        fprintf(fp, "   frequency: ");
        fprintf(fp, "%1d, ", buffer[2]);

        fprintf(fp, "   sampelCounter: ");
        fprintf(fp, "%1d, ", buffer[3]);

        for (int i = 4; i < 64 + 4; i++) {
            fprintf(fp, "  Mic");
            fprintf(fp, "%d, ", (i - 3));
            fprintf(fp, ": ");
            fprintf(fp, "%8d, ", buffer[i]);

            fprintf(fp, "  Mic");
            fprintf(fp, "%d, ", (64 + i - 3));
            fprintf(fp, ": ");
            fprintf(fp, "%8d, ", buffer[64 + i]);

            fprintf(fp, "     ");
        }
        fprintf(fp, "\n");
    }
    return 0;
}