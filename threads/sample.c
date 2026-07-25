#include <stdio.h>
#include <pthread.h>
void *display(void *arg)
{
    printf("Thread executing\n");
    return NULL;
}
int main()
{
    pthread_t t1, t2, t3;
    pthread_create(&t1,NULL,display,NULL);
    pthread_create(&t2,NULL,display,NULL);
    pthread_create(&t3,NULL,display,NULL);
    pthread_join(t1,NULL);
    pthread_join(t2,NULL);
    pthread_join(t3,NULL);
    return 0;
}
