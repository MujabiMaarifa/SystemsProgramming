#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>

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
    for (int i = 0; i < NUM_CATEGORIES; i++) {
        inventory[i].name = category_names[i];
        inventory[i].quantity = 50; // Initial stock
        category_indices[i] = i;
    }
    pthread_mutex_init(&inventory_mutex, NULL);
    srand(time(NULL));
    
    printf("=== Supermarket Inventory Management System ===\n");
    printf("Initial inventory:\n");
    for (int i = 0; i < NUM_CATEGORIES; i++) {
        printf("  %s: %d units\n", inventory[i].name, inventory[i].quantity);
    }
    printf("\nStarting inventory updates...\n\n");
    
    for (int i = 0; i < NUM_CATEGORIES; i++) {
        pthread_create(&threads[i], NULL, update_inventory, &category_indices[i]);
    }
    for (int i = 0; i < NUM_CATEGORIES; i++) {
        pthread_join(threads[i], NULL);
    }
    pthread_mutex_destroy(&inventory_mutex);
    printf("\n=== FINAL INVENTORY SUMMARY ===\n");
    for (int i = 0; i < NUM_CATEGORIES; i++) {
        printf("  %s: %d units\n", inventory[i].name, inventory[i].quantity);
    }
    printf("\nTotal number of stock updates performed: %d\n", total_updates);
    printf("Inventory synchronization completed successfully.\n");
    
    return 0;
}
