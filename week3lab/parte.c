#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>
int main()
{
    pid_t pid;
    pid = fork();
    if(pid==0)
    {
        printf("Child running...\n");
        sleep(3);
        printf("Child finished.\n");
    }
    else
    {
        wait(NULL);
        printf("Parent resumes.\n");
    }
    return 0;
}
