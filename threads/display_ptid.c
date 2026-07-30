#include <stdio.h>
#include <pthread.h>

void *worker(void *arg)
{
    printf("Thread ID: %lu\n", (unsigned long)pthread_self());
    return NULL;
}
int main()
{
    printf("Creating thread ...\n");

    pthread_t t1, t2, t3, t4, t5;

    pthread_create(&t1,NULL,worker,NULL);
    pthread_create(&t2,NULL,worker,NULL);
    pthread_create(&t3,NULL,worker,NULL);
    pthread_create(&t4,NULL,worker,NULL);
    pthread_create(&t5,NULL,worker,NULL);

    pthread_join(t1,NULL);
    pthread_join(t2,NULL);
    pthread_join(t3,NULL);
    pthread_join(t4,NULL);
    pthread_join(t5,NULL);

    return 0;
}
