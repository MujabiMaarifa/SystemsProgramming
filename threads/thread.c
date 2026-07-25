#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

void *message(void *arg)
{
    printf("Hello from the thread!\n");
    return NULL;
}

void *worker(void *arg)
{
    printf("Working...\n;");
    return NULL;
}

//specifies the thread function
int pthread_create(
        pthread_t *thread,
        const pthread_attr_t *attr,
        void *(*start_routine)(void *),
        void *arg
        );

int main() {
    pthread_t id; //create a new thread
    pthread_create(&id, NULL, message, NULL);
    pthread_join(id, NULL); //identifies the thread
    printf("Back in the main thread.");
    return 0;
}
