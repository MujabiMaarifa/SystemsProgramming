#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

#define BUFFER_SIZE 100

int main(void) {
    int pipefd[2];          
    pid_t pid;
    char buffer[BUFFER_SIZE];
    const char *message = "Hello from parent process!";

    if (pipe(pipefd) == -1) {
        perror("pipe failed");
        exit(EXIT_FAILURE);
    }

    pid = fork();

    if (pid < 0) {
        perror("fork failed");
        exit(EXIT_FAILURE);
    }

    if (pid > 0) {
        close(pipefd[0]);                  
        write(pipefd[1], message, strlen(message) + 1);
        close(pipefd[1]);                   
        wait(NULL);                          
        printf("Parent: message sent, child has exited.\n");

    } else {
        close(pipefd[1]);                     
        read(pipefd[0], buffer, BUFFER_SIZE);
        printf("Child: received message -> \"%s\"\n", buffer);
        close(pipefd[0]);
        exit(EXIT_SUCCESS);
    }

    return 0;
}
