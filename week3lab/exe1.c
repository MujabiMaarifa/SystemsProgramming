#include <stdio.h>
#include <unistd.h>
int main()
{
    printf("Current Process ID : %d\n", getpid());
    printf("Parent Process ID : %d\n", getppid());
    return 0;
}
