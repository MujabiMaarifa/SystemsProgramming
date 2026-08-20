#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>

int main(void) {
    int n =5;
    int *arr;

    arr = (int *) malloc(n *sizeof(int));
    if (arr == NULL) {
        printf("Initial memory allocation failed");
        exit(1);
    }

    int new_n = 10;
    int *ARR;
    ARR = (int *)realloc(arr, new_n * sizeof(int));

    if (ARR == NULL) {
        printf("Memory Reallocation failed");
        free(arr);
        exit(1);
    }
    arr = ARR;

    free(arr);
    arr = NULL;
    return 0;
}
