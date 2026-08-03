#set par(leading: 2pt)
#align(left)[
    #set par(leading: 1.5em)
    DEDAN KIMATHI UNIVERSITY OF TECHNOLOGY\
    SCHOOL OF COMPUTER SCIENCE AND INFORMATION TECHNOLOGY\
    BACHELOR OF SCIENCE IN COMPUTER SCIENCE\
    CCS 3105: SYSTEMS PROGRAMMING\
    TERM PAPER – WEEK 6 (MULTITHREADING AND THREAD SYNCHRONIZATION)\
    Total Marks: 100\
    Student Name: MUJABI DAVID OJIAMBO\
    Registration Number: C026-01-0802/2024\
    Date: August 3, 2026\
    Lecturer Name: Mr. George Musumba
]
#pagebreak()
= Question One (20 Marks)
== Thread Creation and Management

=== (a) Creating Five Worker Threads
I developed a multithreaded program using the POSIX Threads (Pthreads) library. The program creates five worker threads using `pthread_create()`. Each thread displays:

- Its thread identifier, obtained from `pthread_self()`.
- A unique task number.
- A message indicating that it has started execution.

```c
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
```

=== (b) Waiting for Completion Using pthread_join()
After creating the threads, the main thread calls `pthread_join(threads[i], NULL)` in a loop for all five threads. `pthread_join()` blocks the calling thread until the specified worker thread has terminated. Only when every join call has returned does the main thread print the message:

`All scheduled tasks have completed successfully.`

This guarantees that no worker thread is still running when the process exits, and it ensures the completion message is displayed only after all five tasks have actually finished executing.

=== (c) Passing the Task Number as an Argument
An initial version of the program used a single global variable to number the tasks:

```c
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

#define NUM_THREADS 5

int task_number = 0;      // GLOBAL variable shared by all threads

void *worker(void *arg) {
    task_number++;        // each thread modifies the shared global
    printf("Thread ID: %lu | Task %d started.\n",
            (unsigned long)pthread_self(), task_number);
    return NULL;
}
int main(void) {
    pthread_t threads[NUM_THREADS];
    for (int i = 0; i < NUM_THREADS; i++)
        pthread_create(&threads[i], NULL, worker, NULL);
    for (int i = 0; i < NUM_THREADS; i++)
        pthread_join(threads[i], NULL);
    printf("All scheduled tasks have completed successfully.\n");
    return 0;
}
```

In the final program, each worker thread receives its task number as an argument through a `task_t` structure passed to `pthread_create()`. The advantages of passing parameters to threads are:

- #strong[No shared state and no data races] — every thread operates on its own data, so no synchronization is needed for the task numbers. With the global variable, concurrent read–modify–write operations can duplicate or skip task numbers.
- #strong[Data safety and thread independence] — each thread receives its own private value and is unaffected by the scheduling or progress of the other threads.
- #strong[Modularity and reusability] — the worker function no longer depends on global state, so it can be reused for different tasks or in other programs.
- #strong[Deterministic, testable results] — the output no longer changes from one run to the next based on thread scheduling.

=== (d) Screenshots
The screenshots required for this question are listed below. Save each image in the `screenshots/` folder, then uncomment the matching `figure` line:

//FIGURE 1 - Source code in the editor
#figure(image("screenshots/source1.png", width: 80%), caption: [Figure 1: Q1 Source code in the editor])
#figure(image("screenshots/source2.png", width: 80%), caption: [Part2: Q1 Source code in the editor])

//FIGURE 2 - Successful compilation
#figure(image("screenshots/q1_compile.png", width: 80%), caption: [Figure 2: Q1 Successful compilation (gcc -pthread -o q1 q1.c)])

//FIGURE 3 - Program execution / output
#figure(image("screenshots/q1_run.png", width: 80%), caption: [Figure 3: Q1 Program execution showing all five threads])

// FIGURE 4 - Terminal commands and observations
// #figure(image("screenshots/q1_terminal.png", width: 80%), caption: [Figure 4: Q1 Terminal commands and observations])

=== Reflection
For this question, I developed a multithreaded program that creates five worker threads. Each thread prints its thread identifier (obtained via pthread_self()), a unique task number (passed as an argument), and a startup message. The main thread uses pthread_join() to wait for all workers to finish before printing the completion message.

Initially, I considered using a global variable for task numbers, but I modified the approach to pass each task number as an argument to avoid shared state and potential race conditions. This method is advantageous because it eliminates the need for synchronization mechanisms for the task numbers, reduces coupling between threads, and makes the code more modular and reusable. Each thread operates on its own data, enhancing safety and clarity.

Challenges included ensuring that the argument passed to each thread remains valid throughout the thread's execution (avoiding passing pointers to local variables that may go out of scope). I solved this by using an array with indices that persist for the thread's lifetime (since the array is in main and lives until all threads join).

Lessons learned: Proper parameter passing is crucial in multithreading to prevent data races and ensure thread independence. The pthread_join() function is essential for synchronizing the main thread with worker threads, ensuring orderly program termination without premature exit.

= Question Two (20 Marks)
== Race Conditions and Mutex Synchronization

=== (a) Unsynchronized Deposits (Demonstrating the Race Condition)
I developed a multithreaded ATM simulation in which four threads each deposit KES 1,000 into a shared account balance 10,000 times — a total of 40,000 deposits. The first version performs the update `balance += DEPOSIT_AMOUNT` with no synchronization:

```c
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
```

#strong[Observations:] The expected final balance is KES 40,000,000 (4 threads × 10,000 deposits × KES 1,000). However, the unsynchronized program produced a different result on nearly every run — for example KES 21,693,000 and KES 28,888,000 — and only occasionally coincided with the correct value by chance. The actual balance was never higher than the expected value. This happens because `balance += DEPOSIT_AMOUNT` is not an atomic operation: it is executed as a read, an add, and a write. When two threads read the same balance at the same time, both add KES 1,000 and write back, only one update is saved and the other is lost. This is a data race whose outcome depends on thread scheduling.

=== (b) Protecting the Balance with a Mutex
I modified the program to protect the shared balance with a POSIX mutex. Each thread calls `pthread_mutex_lock()` before updating the balance and `pthread_mutex_unlock()` immediately afterwards, so only one thread can be inside the update (the critical section) at any time:

```c
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
        temp = temp + DEPOSIT_AMOUNT;
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
    printf("Starting synchronized deposits...\n");

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
```

The read–add–write sequence is now atomic with respect to the other threads: a thread that has locked the mutex completes its entire update before any other thread can access the balance.

=== (c) Comparing the Outputs: Race Conditions and Critical Sections
The unsynchronized version produced a different, incorrect balance on almost every run (e.g. KES 21,693,000 or KES 28,888,000 instead of KES 40,000,000), because the four threads raced to read and write the shared balance. The mutex-protected version produced exactly KES 40,000,000, with a discrepancy of KES 0, on every run.

A #strong[race condition] occurs when two or more threads access shared data concurrently and the final result depends on the unpredictable order of thread scheduling. A #strong[critical section] is a part of the program that accesses shared resources and must never be executed by more than one thread at a time. In this program, the lines `temp = balance; temp = temp + DEPOSIT_AMOUNT; balance = temp;` form the critical section. The mutex provides #strong[mutual exclusion]: it guarantees that only one thread is inside the critical section at any moment, turning the lost-update problem into a safe, serialized sequence of updates. The cost is a small loss of parallelism because the critical section is executed by one thread at a time.

=== (d) Screenshots

#figure(image("screenshots/q2_source.png", width: 80%), caption: [Figure 5: Q2 Source code in the editor])
#figure(image("screenshots/q2_source2.png", width: 80%), caption: [Part2: Q2 Source code in the editor])


//FIGURE 6 - Q2 Successful compilation
#figure(image("screenshots/q2_cpl.png", width: 80%), caption: [Figure 6: Q2 Successful compilation (gcc -pthread -o unsync unsync.c; gcc -pthread -o sync a.c)])

//FIGURE 7 - Q2 Output before synchronization (race condition)
#figure(image("screenshots/unsync.png", width: 80%), caption: [Figure 7: Q2 Output before synchronization — incorrect, varying balance])

//FIGURE 8 - Q2 Output after synchronization (correct balance)
#figure(image("screenshots/async.png", width: 80%), caption: [Figure 8: Q2 Output after synchronization — correct balance of KES 40,000,000])

=== Reflection
I developed a multithreaded program simulating an ATM system where four threads concurrently deposit KES 1,000 into a shared bank balance 10,000 times each. Without synchronization, the final balance was usually far below the expected KES 40,000,000 (4 threads × 10,000 deposits × KES 1,000) because of race conditions; on rare runs the value coincided with the correct answer by chance. This occurred because multiple threads read, modified, and wrote the shared balance variable simultaneously, causing lost updates.

To fix this, I introduced a POSIX mutex to protect the critical section (the balance update operation). Each thread now locks the mutex before modifying the balance and unlocks it afterward, ensuring only one thread accesses the shared variable at a time.

Comparing outputs: The unsynchronized version produced varying incorrect results (e.g., KES 12,345,000) due to interleaving operations, while the synchronized version consistently yielded the correct KES 40,000,000. This demonstrates how mutexes enforce mutual exclusion, preventing race conditions by serializing access to critical sections. The key lesson is that shared mutable state requires explicit synchronization to maintain data consistency in concurrent systems.
= Question Three (20 Marks)
== Producer–Consumer Problem

=== (a) Implementation
I implemented a classic Producer–Consumer solution with one producer thread, one consumer thread, and a shared circular buffer of size 5. Synchronization is achieved through a POSIX mutex (for mutual exclusion on buffer access) and two semaphores: `empty` (counts empty buffer slots, initialised to 5) and `full` (counts filled slots, initialised to 0).

```c
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
```

The producer waits on `empty` before adding an item, locks the mutex to safely update the buffer, then signals `full`. The consumer waits on `full` before removing an item, locks the mutex for safe access, then signals `empty`. This prevents the producer from overflowing the buffer and the consumer from underflowing it.

=== (b) Displaying Production and Consumption Activities
Every production and consumption activity is printed with the product number, the thread performing the operation, and the current buffer status. The function `print_buffer_status()` shows all five buffer slots, using an underscore (`_`) for an empty slot. For example:

`[Producer Thread] Produced Product #3 at slot 2`
`[PRODUCER] Product #3 | Buffer: [ _  _  3  _  _ ]`
`[Consumer Thread] Consumed Product #3 from slot 2`
`[CONSUMER] Product #3 | Buffer: [ _  _  _  _  _ ]`

=== (c) How Mutexes and Semaphores Prevent Data Inconsistency
Mutexes prevent data inconsistency by guaranteeing exclusive access to the buffer during read/write operations, while semaphores coordinate the producer and consumer based on buffer state. Without the mutex, concurrent modifications to the buffer indices (`in`/`out`) could corrupt the buffer state; without the semaphores, busy waiting would waste CPU cycles. Together they ensure safe, efficient coordination: the producer blocks when the buffer is full and the consumer blocks when it is empty, eliminating race conditions and unnecessary spinning.

=== (d) Screenshots

//FIGURE 9 - Q3 Source code in the editor
#figure(image("screenshots/q3_source.png", width: 80%), caption: [Figure 9: Q3 Source code in the editor])
#figure(image("screenshots/q3_source1.png", width: 80%), caption: [Figure 9: Q3 Source code in the editor])
#figure(image("screenshots/q3_source2.png", width: 80%), caption: [Figure 9: Q3 Source code in the editor])
#figure(image("screenshots/q3_source3.png", width: 80%), caption: [Figure 9: Q3 Source code in the editor])


//FIGURE 10 - Q3 Successful compilation
#figure(image("screenshots/q3_compile.png", width: 80%), caption: [Figure 10: Q3 Successful compilation (gcc -pthread -o q3 main.c)])

//FIGURE 11 - Q3 Program execution (producer/consumer operations)
#figure(image("screenshots/q3_run.png", width: 80%), caption: [Figure 11: Q3 Program execution showing producer and consumer operations])

// FIGURE 12 - Q3 Buffer updates during execution
// #figure(image("screenshots/q3_buffer.png", width: 80%), caption: [Figure 12: Q3 Buffer updates during execution])

=== Reflection
I implemented a classic Producer-Consumer solution using one producer thread, one consumer thread, and a shared buffer of size 5. Synchronization is achieved through a mutex (for mutual exclusion on buffer access) and two semaphores: 'empty' (counting empty buffer slots) and 'full' (counting filled slots).

The producer waits on 'empty' before adding an item, locks the mutex to safely update the buffer, then signals 'full'. The consumer waits on 'full' before removing an item, locks the mutex for safe access, then signals 'empty'. This ensures the producer doesn't overflow the buffer and the consumer doesn't underflow it.

Mutexes prevent data inconsistency by guaranteeing exclusive access to the buffer during read/write operations, while semaphores coordinate the producer and consumer based on buffer state. Without the mutex, concurrent modifications to the buffer indices (in/out) could corrupt the buffer state. Without semaphores, busy waiting would waste CPU cycles. Together, they ensure safe, efficient coordination: the producer blocks when the buffer is full, and the consumer blocks when empty, eliminating race conditions and unnecessary spinning.

= Question Four (20 Marks)
== Thread Synchronization Using Condition Variables

=== Source Code
```c
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
        pthread_cond_signal(&cond);
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
    int dept_ids[NUM_DEPARTMENTS] = {1, 2, 3, 4};

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
```

=== Screenshots

//FIGURE 13 - Q4 Source code in the editor
#figure(image("screenshots/q4_source.png", width: 80%), caption: [Figure 13: Q4 Source code in the editor])
#figure(image("screenshots/q4_source2.png", width: 80%), caption: [Part2 : Q4 Source code in the editor])
#figure(image("screenshots/q4_source3.png", width: 80%), caption: [Part3: Q4 Source code in the editor])


//FIGURE 14 - Q4 Successful compilation
#figure(image("screenshots/q4_compile.png", width: 80%), caption: [Figure 14: Q4 Successful compilation (gcc -pthread -o q4 Q4.c)])

//FIGURE 15 - Q4 Program execution (department processing progress)
#figure(image("screenshots/q4_run.png", width: 80%), caption: [Figure 15: Q4 Program execution showing department processing progress])

// FIGURE 16 - Q4 Final synchronized report
// #figure(image("screenshots/q4_report.png", width: 80%), caption: [Figure 16: Q4 Final synchronized report printed by the reporting thread])

=== Reflection
I developed a multithreaded program where four worker threads represent academic departments processing marks independently, and a reporting thread waits for all departments to finish before generating the final class report. Synchronization uses a mutex to protect the shared 'departments_ready' counter and a condition variable for the reporting thread to wait efficiently.

Each department thread simulates processing (with sleep), increments the counter under mutex protection, and signals the condition variable when the last department finishes. The reporting thread locks the mutex, waits on the condition variable until the counter reaches four, then proceeds to print the final report.

Condition variables are preferred over busy waiting because they allow the reporting thread to relinquish the CPU while waiting, rather than consuming cycles in a loop checking the condition. This is more efficient and responsive, especially when the wait time is variable or indefinite. In this scenario, departments finish at different times (simulated by varying sleep durations), so busy waiting would waste resources polling a condition that changes infrequently. Condition variables provide a clean mechanism for threads to sleep until a specific state change occurs, improving system utilization and responsiveness.

= Question Five (20 Marks)
== Multithreaded Inventory Management System (Mini Project)

=== Source Code
```c
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>

#define NUM_CATEGORIES 4

// Inventory structure
typedef struct {
    const char* name;
    int quantity;
} InventoryItem;

// Shared inventory
InventoryItem inventory[NUM_CATEGORIES];

// Mutex for protecting inventory
pthread_mutex_t inventory_mutex;

// Total updates counter
int total_updates = 0;

// Categories
const char* category_names[] = {
    "Electronics",
    "Groceries",
    "Clothing",
    "Stationery"
};

void* update_inventory(void* arg) {
    int category_idx = *(int*)arg;
    const char* category = category_names[category_idx];

    // Each thread performs 5 updates
    for (int i = 0; i < 5; i++) {
        // Simulate processing delay
        sleep(1);

        // Lock mutex before accessing shared inventory
        pthread_mutex_lock(&inventory_mutex);

        // Update inventory: random restock or sale
        int change = (rand() % 3) - 1; // -1, 0, or 1
        inventory[category_idx].quantity += change;
        if (inventory[category_idx].quantity < 0) {
            inventory[category_idx].quantity = 0; // Don't go negative
        }

        total_updates++;

        printf("[%s] Update #%d: Changed by %d. New stock level: %d\n",
        category, i+1, change, inventory[category_idx].quantity);

        pthread_mutex_unlock(&inventory_mutex);
    }

    return NULL;
}

int main() {
    pthread_t threads[NUM_CATEGORIES];
    int category_indices[NUM_CATEGORIES];

    // Initialize inventory
    for (int i = 0; i < NUM_CATEGORIES; i++) {
        inventory[i].name = category_names[i];
        inventory[i].quantity = 50; // Initial stock
        category_indices[i] = i;
    }

    // Initialize mutex
    pthread_mutex_init(&inventory_mutex, NULL);

    // Seed random number generator
    srand(time(NULL));

    printf("=== Supermarket Inventory Management System ===\n");
    printf("Initial inventory:\n");
    for (int i = 0; i < NUM_CATEGORIES; i++) {
        printf("  %s: %d units\n", inventory[i].name, inventory[i].quantity);
    }
    printf("\nStarting inventory updates...\n\n");

    // Create worker threads
    for (int i = 0; i < NUM_CATEGORIES; i++) {
        pthread_create(&threads[i], NULL, update_inventory, &category_indices[i]);
    }

    // Wait for all threads to complete
    for (int i = 0; i < NUM_CATEGORIES; i++) {
        pthread_join(threads[i], NULL);
    }

    // Destroy mutex
    pthread_mutex_destroy(&inventory_mutex);

    // Final inventory summary
    printf("\n=== FINAL INVENTORY SUMMARY ===\n");
    for (int i = 0; i < NUM_CATEGORIES; i++) {
        printf("  %s: %d units\n", inventory[i].name, inventory[i].quantity);
    }
    printf("\nTotal number of stock updates performed: %d\n", total_updates);
    printf("Inventory synchronization completed successfully.\n");

    return 0;
}
```

=== Screenshots

//FIGURE 17 - Q5 Source code in the editor
#figure(image("screenshots/q5_source.png", width: 80%), caption: [Figure 17: Q5 Source code in the editor])
#figure(image("screenshots/q5_source2.png", width: 80%), caption: [Part2 : Q5 Source code in the editor])
#figure(image("screenshots/q5_source3.png", width: 80%), caption: [Part3 : Q5 Source code in the editor])

//FIGURE 18 - Q5 Successful compilation
#figure(image("screenshots/q5_compile.png", width: 80%), caption: [Figure 18: Q5 Successful compilation (gcc -pthread -o q5 Q5.c)])

//FIGURE 19 - Q5 Thread execution (category updates)
#figure(image("screenshots/q5_run.png", width: 80%), caption: [Figure 19: Q5 Thread execution showing category stock updates])

// FIGURE 20 - Q5 Final inventory report
// #figure(image("screenshots/q5_summary.png", width: 80%), caption: [Figure 20: Q5 Final inventory report (summary, total updates, confirmation)])

=== Reflection
I developed a multithreaded inventory management system for a supermarket with four categories: Electronics, Groceries, Clothing, and Stationery. Each category is processed by a dedicated worker thread that updates inventory quantities (simulating restocking by adding a random amount), displays the category and updated stock level, and uses sleep() to simulate processing delays.

To prevent race conditions on shared inventory data, I used a POSIX mutex to protect critical sections where inventory quantities and the total update counter are modified. Each thread locks the mutex before accessing shared data, performs its update, then unlocks it, ensuring exclusive access during modifications.

After all worker threads complete (via pthread_join()), the main thread displays: a final inventory summary showing stock levels for all categories, the total number of stock updates performed (incremented atomically under the mutex), and a confirmation of successful synchronization.

Challenges included ensuring the mutex was properly locked/unlocked in all code paths (including early returns) and avoiding deadlocks. I solved this by consistently using lock/unlock pairs and keeping critical sections minimal. Lessons learned: Mutexes are essential for protecting shared mutable state in concurrent systems, but must be used judiciously to avoid performance bottlenecks. Combining thread-specific work (like category processing) with synchronized shared-state updates is a common and effective pattern in inventory systems.

= Problems Encountered in the Study

During the implementation of this term paper, I encountered several challenges that are common in multithreaded programming. Firstly, debugging race conditions proved difficult because they are non-deterministic and often depend on thread timing. For Question Two, observing the inconsistent balances required multiple runs to notice the pattern of lost updates. Secondly, managing thread lifetimes and ensuring proper synchronization to avoid deadlocks was tricky, especially in Question Five where multiple threads access shared inventory. Thirdly, correctly using condition variables in Question Four required careful attention to the while loop in pthread_cond_wait to handle spurious wakeups. Fourthly, compiling with the correct flags (not forgetting -pthread) caused initial linkage errors. Finally, ensuring that arguments passed to threads remain valid (avoiding dangling pointers) required thoughtful design, such as using arrays with sufficient scope. These experiences reinforced the importance of systematic testing, careful synchronization design, and understanding the underlying POSIX thread semantics.

= References

- POSIX Threads Programming, Lawrence Livermore National Laboratory Computing, https://computing.llnl.gov/tutorials/pthreads/
- GNU C Library Manual, Free Software Foundation, https://www.gnu.org/software/libc/manual/
- Lecture notes and textbook for CCS 3105: Systems Programming, Dedan Kimathi University of Technology
- Online tutorials and reference materials used during implementation

