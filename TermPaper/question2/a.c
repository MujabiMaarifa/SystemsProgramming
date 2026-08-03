#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

#define NUM_THREADS   4
#define NUM_DEPOSITS  10000
#define DEPOSIT_AMOUNT 1000

long balance = 0;   
pthread_mutex_t protected_balance;

void *deposit(void *arg) {
    int id = *(int *) arg;
    for (int i = 0; i < NUM_DEPOSITS; i++) {
        pthread_mutex_lock(&protected_balance);
        long temp = balance;       
        temp =temp +DEPOSIT_AMOUNT;
        balance = temp;           
        pthread_mutex_unlock(&protected_balance);
    }
    printf("Thread %d finished depositing.\n", id);
    return NULL;
}
int main(void) {
    pthread_t threads[NUM_THREADS];
    int ids[NUM_THREADS];
    if (pthread_mutex_init(&protected_balance, NULL) != 0) {
        perror("Failed to initialize mutex");
        return 1;
    }

    printf("\n ============================== ATM SIMULATION ==============================\n");
    printf("Initial Shared balance  : %ld KES\n", balance);
    printf("Deposits per threads    : %d times\n", NUM_DEPOSITS);
    printf("Number of Threads       : %d\n\n", NUM_THREADS); 
    sleep(2);
    printf("Starting synchronized deposits...\n");

    sleep(2);
    for (int i = 0; i < NUM_THREADS; i++) {
        ids[i] = i + 1;
        pthread_create(&threads[i], NULL, deposit, &ids[i]);
    }
    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }

    long expected = (long) NUM_THREADS * NUM_DEPOSITS * DEPOSIT_AMOUNT;
    pthread_mutex_destroy(&protected_balance);
    printf("\nExpected balance: KES %ld\n", expected);
    printf("Actual balance:   KES %ld\n", balance);
    printf("Discrepancy: KES %ld\n", expected - balance);

    return 0;
}



