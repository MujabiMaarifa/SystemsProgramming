#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>

int main(void) {
    int fd;
    fd = open("log.txt", O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd == -1) {
        perror("Open failed");
        return EXIT_FAILURE;
    }
    // now redirect the descriptor
    dup2(fd, STDOUT_FILENO);
    printf("File descriptors done -- This can be seen in the login pages, linux shell redirection.\n");
    return 0;
}

