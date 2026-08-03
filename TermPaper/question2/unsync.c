#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

#define NUM_THREADS   4
#define NUM_DEPOSITS  10000
#define DEPOSIT_AMOUNT 1000

long balance = 0;

void *deposit(void *arg) {
    int id = *(int *) arg;
    for (int i = 0; i < NUM_DEPOSITS; i++) {
        balance += DEPOSIT_AMOUNT;   // unsafe: race condition
    }
    printf("Thread %d finished depositing.\n", id);
    return NULL;
}
int main(void) {
    pthread_t threads[NUM_THREADS];
    int ids[NUM_THREADS];

    printf("\n ============================== ATM SIMULATION ==============================\n");
    printf("Initial Shared balance  : %ld KES\n", balance);
    printf("Deposits per threads    : %d times\n", NUM_DEPOSITS);
    printf("Number of Threads       : %d\n\n", NUM_THREADS);
    printf("Starting unsynchronized deposits...\n");

    for (int i = 0; i < NUM_THREADS; i++) {
        ids[i] = i + 1;
        pthread_create(&threads[i], NULL, deposit, &ids[i]);
    }
    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }

    long expected = (long) NUM_THREADS * NUM_DEPOSITS * DEPOSIT_AMOUNT;
    printf("\nExpected balance: KES %ld\n", expected);
    printf("Actual balance:   KES %ld\n", balance);
    printf("Discrepancy: KES %ld\n", expected - balance);

    return 0;
}
