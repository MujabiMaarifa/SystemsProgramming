#include <stdio.h> 
int main() {
    char name[50];
    int age;
    char course_name[100];
    printf("Enter your name: ");
    scanf("%s", name);
    printf("Enter your age: ");
    scanf("%d", &age);
    printf("Enter Course Name: ");
    scanf("%s", course_name);
    
    printf("Name: %s ", name);
    printf("\nAge: %d\n", age);
    printf("Course: %s\n", course_name);
    return 0;
}
