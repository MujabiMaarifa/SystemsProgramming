#include <stdio.h>
#include <pthread.h>

void *worker(void *arg)
{
    printf("Thread ID: %lu\n", (unsigned long)pthread_self());
    return NULL;
}
int main()
{
    pthread_t t1;
    pthread_create(&t1,NULL,worker,NULL);
    pthread_join(t1,NULL);
    return 0;
}
