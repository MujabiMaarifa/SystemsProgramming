#include <stdio.h>
#include <unistd.h>
int main()
{
    int number = 100;
    if(fork()==0)
    {
        number = 200;
        printf("Child: %d\n",number);
    }
    else
    {
        printf("Parent: %d\n",number);
    }
    return 0;
}
