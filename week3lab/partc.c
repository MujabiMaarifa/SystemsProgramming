#include <stdio.h>
#include <unistd.h>
int main()
{
    pid_t pid;
    pid= fork();
    if(pid<0)
    {
        perror("Fork Failed");
        return 1;
    }       else
    {
        printf("Parent Process\n");
        printf("PID = %d\n", getpid());
    }
    return 0;
}
