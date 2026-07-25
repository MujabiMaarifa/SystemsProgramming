#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>

int main() {
    printf("Standard input : %d\n", STDIN_FILENO);
    printf("Standard output: %d\n", STDOUT_FILENO);
    printf("Standard error: %d\n", STDERR_FILENO);

    int fdescriptor = open("example.txt", O_RDWR | O_CREAT | O_APPEND, 000);
    printf("%d\n", fdescriptor);

    char *foo = "Systems Programming Practical";
    char buffer[1024] = {0};
    write(fdescriptor, foo, strlen(foo));
    size_t bytes = read(fdescriptor, buffer, sizeof(buffer));
    printf("%d", bytes);

    return 0;
}
