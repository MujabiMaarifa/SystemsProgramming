#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

#define NUM_THREADS 5

typedef struct {
    int task_number;
    char task_name[20];
} task_t;

void *worker(void *arg) {
    task_t *task = (task_t *) arg;
    printf("Thread ID: %lu | Task %d (%s) started.\n",
            (unsigned long)pthread_self(), task->task_number, task->task_name);
    return NULL;
}
int main(void) {
    pthread_t threads[NUM_THREADS];
    task_t tasks[NUM_THREADS];
    printf("Thread execution will start in 2 seconds ... \n\n");
    sleep(2);
    // create threads tasks
    for (int i = 0; i < NUM_THREADS; i++) {
        tasks[i].task_number = i + 1;
        snprintf(tasks[i].task_name, sizeof(tasks[i].task_name), "Task-%d", i + 1);
        pthread_create(&threads[i], NULL, worker, &tasks[i]);
    }
    // we wait for threads to finish execution
    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }
    printf("All scheduled tasks have completed successfully.\n");
    return 0;
}
