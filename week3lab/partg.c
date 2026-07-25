#include <stdio.h>
#include <unistd.h>
int main()
{
    for(int i=0;i<3;i++)
    {
        fork();
        printf("PID=%d\n",getpid());
    }
    return 0;
}
