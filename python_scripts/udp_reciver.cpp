#include <arpa/inet.h>
#include <unistd.h>

#include <chrono>
#include <cstring>
#include <fstream>
#include <iostream>
#include <thread>
#include <vector>

#define UDP_PORT 21875
#define BUFFER_SIZE 1458

void udpReceiver(const std::string &filename, int recordTime) {
  int sockfd;
  struct sockaddr_in serverAddr{};
  socklen_t addrLen = sizeof(serverAddr);

  // Create socket
  sockfd = socket(AF_INET, SOCK_DGRAM, 0);
  if (sockfd < 0) {
    std::cerr << "Error creating socket\n";
    return;
  }

  // Set socket buffer size, see github wiki to enable bigger buffer
  int bufferSize = 8 * 1024 * 1024;  // 8MB buffer
  setsockopt(sockfd, SOL_SOCKET, SO_RCVBUF, &bufferSize, sizeof(bufferSize));

  // Uncomment to check the actual buffer size alocated on your computer
  // int actualSize;
  // socklen_t optLen = sizeof(actualSize);
  // getsockopt(sockfd, SOL_SOCKET, SO_RCVBUF, &actualSize, &optLen);
  // std::cout << "Actual receive buffer size: " << actualSize << " bytes\n";

  serverAddr.sin_family = AF_INET;
  serverAddr.sin_addr.s_addr = INADDR_ANY;
  serverAddr.sin_port = htons(UDP_PORT);

  // Bind socket
  if (bind(sockfd, (struct sockaddr *)&serverAddr, sizeof(serverAddr)) < 0) {
    std::cerr << "Error binding socket\n";
    close(sockfd);
    return;
  }

  std::cout << "Recording...\n";

  // Open binary file for writing
  std::ofstream outFile(filename, std::ios::binary);
  if (!outFile.is_open()) {
    std::cerr << "Error opening file\n";
    close(sockfd);
    return;
  }

  char buffer[BUFFER_SIZE];
  auto startTime = std::chrono::steady_clock::now();

  while (std::chrono::steady_clock::now() - startTime <
         std::chrono::seconds(recordTime)) {
    ssize_t recvLen = recvfrom(sockfd, buffer, BUFFER_SIZE, 0,
                               (struct sockaddr *)&serverAddr, &addrLen);
    if (recvLen < 0) {
      std::cerr << "Error receiving data\n";
      continue;
    }

    // Write raw binary data directly
    outFile.write(buffer, recvLen);
  }

  std::cout << "Recording complete!\n";

  outFile.close();
  close(sockfd);
}

int main() {
  std::string filename;
  int recordTime;

  std::cout << "Enter filename for the recording: ";
  std::cin >> filename;
  filename = "./recorded_data/v22_3/" + filename + ".bin";

  // std::cout << "Enter time to record (seconds): ";
  // std::cin >> recordTime;
  recordTime = 5;

  udpReceiver(filename, recordTime);
  std::cout << "\n";

  return 0;
}
