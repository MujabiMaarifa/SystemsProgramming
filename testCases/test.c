#include <stdio.h>
#include <pthread.h>

int main(void) {
    //pthread_self() returns the id of the running thread
    pthread_t me = pthread_self();
    printf("The value of me: %lu", (unsigned long)me);
    //pthread_join()->returns instantly once the running thread has terminated
    
    return 0;
}
