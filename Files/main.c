#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

int main(void) {
    int fd;
    char *data = "CAT Marks: 24/30 \n";

    fd = open("marks.txt", O_WRONLY | O_CREAT, 0644);
    if(fd == -1) {
        perror("File opening failed");
        exit(1);
    }
    write(fd, data, strlen(data));

    close(fd);
    return 0;
}
