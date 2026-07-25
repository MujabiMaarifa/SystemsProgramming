#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define NUM_THREADS 4

void *greet(void *arg) {
    long id = (long)arg;
    printf("Hello from thread %ld (Thread ID: %lu)\n", id, pthread_self());
    pthread_exit(NULL);
}

int main() {
    pthread_t threads[NUM_THREADS];
    int rc;

    for (long i = 0; i < NUM_THREADS; i++) {
        rc = pthread_create(&threads[i], NULL, greet, (void *)i);
        if (rc) {
            fprintf(stderr, "Error: pthread_create failed with code %d\n", rc);
            exit(EXIT_FAILURE);
        }
    }

    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }

    printf("All threads have completed.\n");
    return 0;
}
