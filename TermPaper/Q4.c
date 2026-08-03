#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

#define NUM_DEPARTMENTS 4

pthread_mutex_t mutex;
pthread_cond_t cond;
int departments_ready = 0;

void* department_processing(void* arg) {
    int dept_id = *(int*)arg;
    
    // Simulate processing marks
    printf("Department %d: Starting marks processing...\n", dept_id);
    sleep(dept_id + 1); // Variable processing time
    
    pthread_mutex_lock(&mutex);
    departments_ready++;
    printf("Department %d: Finished processing. Departments ready: %d/%d\n", 
           dept_id, departments_ready, NUM_DEPARTMENTS);
    if (departments_ready == NUM_DEPARTMENTS) {
        pthread_cond_signal(&cond); // Signal the reporting thread
    }
    pthread_mutex_unlock(&mutex);
    
    return NULL;
}

void* reporting_thread(void* arg) {
    pthread_mutex_lock(&mutex);
    while (departments_ready < NUM_DEPARTMENTS) {
        printf("Reporting thread: Waiting for departments to finish...\n");
        pthread_cond_wait(&cond, &mutex);
    }
    pthread_mutex_unlock(&mutex);
    
    printf("\n=== FINAL CLASS REPORT ===\n");
    printf("All departments have submitted their marks.\n");
    printf("Generating final class report...\n");
    printf("Report completed successfully.\n");
    
    return NULL;
}

int main() {
    pthread_t dept_threads[NUM_DEPARTMENTS];
    pthread_t report_thread;
    int dept_ids[NUM_DEPARTMENTS];
    
    pthread_mutex_init(&mutex, NULL);
    pthread_cond_init(&cond, NULL);
    
    // Create reporting thread
    pthread_create(&report_thread, NULL, reporting_thread, NULL);
    
    // Create department threads
    for (int i = 0; i < NUM_DEPARTMENTS; i++) {
        dept_ids[i] = i + 1; // Department IDs 1-4
        pthread_create(&dept_threads[i], NULL, department_processing, &dept_ids[i]);
    }
    
    // Wait for department threads
    for (int i = 0; i < NUM_DEPARTMENTS; i++) {
        pthread_join(dept_threads[i], NULL);
    }
    
    // Wait for reporting thread
    pthread_join(report_thread, NULL);
    
    pthread_mutex_destroy(&mutex);
    pthread_cond_destroy(&cond);
    
    return 0;
}

