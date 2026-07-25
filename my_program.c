#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

#define BUFFER_SIZE 256

int main() {
    char filename[100];
    char buffer[BUFFER_SIZE];
    ssize_t bytesRead;
    int fd;

    printf("Enter filename to read: ");
    scanf("%99s", filename);

    fd = open(filename, O_RDONLY);
    if (fd == -1) {
        fprintf(stderr, "Error: could not open file '%s': %s\n", filename, strerror(errno));
        exit(EXIT_FAILURE);
    }

    printf("\n----- File contents -----\n");
    while ((bytesRead = read(fd, buffer, BUFFER_SIZE - 1)) > 0) {
        buffer[bytesRead] = '\0';
        printf("%s", buffer);
    }

    if (bytesRead == -1) {
        fprintf(stderr, "Error reading file: %s\n", strerror(errno));
        close(fd);
        exit(EXIT_FAILURE);
    }
    printf("\n--------------------------\n");

    if (close(fd) == -1) {
        fprintf(stderr, "Error closing file: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    return 0;
}
