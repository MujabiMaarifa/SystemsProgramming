#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>

#define BUFFER_SIZE 5
#define TOTAL_ITEMS 10   

int buffer[BUFFER_SIZE];
int in = 0;   
int out = 0; 

pthread_mutex_t mutex;      
sem_t empty;               
sem_t full;               

void print_buffer_status(const char *action, int product_no) {
    printf("[%s] Product #%d | Buffer: [", action, product_no);
    for (int i = 0; i < BUFFER_SIZE; i++) {
        if (buffer[i] == -1)
            printf(" _ ");
        else
            printf(" %d ", buffer[i]);
    }
    printf("]\n");
}

void *producer(void *arg) {
    for (int i = 1; i <= TOTAL_ITEMS; i++) {
        sem_wait(&empty);              // wait for an empty slot
        pthread_mutex_lock(&mutex);    // enter critical section

        buffer[in] = i;
        printf("[Producer Thread] Produced Product #%d at slot %d\n", i, in);
        print_buffer_status("PRODUCER", i);
        in = (in + 1) % BUFFER_SIZE;

        pthread_mutex_unlock(&mutex);  // leave critical section
        sem_post(&full);               // signal a new filled slot

        usleep(300000); // simulate production time
    }
    return NULL;
}

void *consumer(void *arg) {
    for (int i = 1; i <= TOTAL_ITEMS; i++) {
        sem_wait(&full);               // wait for a filled slot
        pthread_mutex_lock(&mutex);    // enter critical section

        int product = buffer[out];
        printf("[Consumer Thread] Consumed Product #%d from slot %d\n", product, out);
        buffer[out] = -1;
        print_buffer_status("CONSUMER", product);
        out = (out + 1) % BUFFER_SIZE;

        pthread_mutex_unlock(&mutex);  // leave critical section
        sem_post(&empty);              // signal a new empty slot

        usleep(500000); // simulate consumption time
    }
    return NULL;
}

int main() {
    pthread_t prod_thread, cons_thread;

    for (int i = 0; i < BUFFER_SIZE; i++) buffer[i] = -1;

    pthread_mutex_init(&mutex, NULL);
    sem_init(&empty, 0, BUFFER_SIZE); 
    sem_init(&full, 0, 0);           

    printf("=== Warehouse Producer-Consumer Simulation Started ===\n\n");

    pthread_create(&prod_thread, NULL, producer, NULL);
    pthread_create(&cons_thread, NULL, consumer, NULL);

    pthread_join(prod_thread, NULL);
    pthread_join(cons_thread, NULL);

    pthread_mutex_destroy(&mutex);
    sem_destroy(&empty);
    sem_destroy(&full);

    printf("\n=== Simulation Complete: All products processed ===\n");
    return 0;
}


