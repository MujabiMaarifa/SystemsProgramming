#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

    int
main(void)
{
    pid_t pid;

    if (signal(SIGCHLD, SIG_IGN) == SIG_ERR) {
        perror("signal");
        exit(EXIT_FAILURE);
    }
    pid = fork();
    switch (pid) {
        case -1:
            perror("fork");
            exit(EXIT_FAILURE);
        case 0:
            puts("Child exiting.");
            fflush(stdout);
            _exit(EXIT_SUCCESS);
        default:
            printf("Child is PID %jd -- This is returned by the fork\n", (intmax_t) pid);
            printf("Parent id: %d\n", getpid());
            puts("Parent exiting.");
            exit(EXIT_SUCCESS);       }
}
