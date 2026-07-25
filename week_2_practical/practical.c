#include <stdio.h>
#include <string.h>

int sum(int a, int b) {
    return a + b;
}

int main(void) {
    char studentName[100];
    char reg[15];
    int a, b;

    printf("Enter the student name: ");
    if (fgets(studentName, sizeof(studentName), stdin)) {
        // remove trailing newline
        studentName[strcspn(studentName, "\n")] = '\0';
    }

    printf("Enter Registration Number: ");
    if (fgets(reg, sizeof(reg), stdin)) {
        reg[strcspn(reg, "\n")] = '\0';
    }

    printf("Name: %s\n", studentName);
    printf("Reg No: %s\n", reg);

    printf("\n");
    printf("Enter the first number: ");
    if (scanf("%d", &a) != 1) {
        fprintf(stderr, "Invalid input for first number\n");
        return 1;
    }
    printf("Enter the second number: ");
    if (scanf("%d", &b) != 1) {
        fprintf(stderr, "Invalid input for stderr");
        return 1;
    }

    int result = sum(a, b);
    printf("The sum of: %d and %d = %d\n", a, b, result);
    return 0;
}