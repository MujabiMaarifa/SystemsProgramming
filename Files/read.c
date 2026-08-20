#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

int main(void) {
    int fd;
    fd = open("marks.txt", O_RDONLY);
    if (fd == -1) {
        perror("File not found here mate!!");
        exit(1);
    }
    
    printf("File descriptor: %d\n", fd);
    printf("File has been found");
    close(fd);
    
    return 0;
}

