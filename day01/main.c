#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

#define SUCCESS 0
#define FAILURE 1
typedef unsigned long u64;

static FILE *fp = NULL;
static char *buffer = NULL;
u64 length = 0;

static u64 converge_left(char *);
static u64 converge_right(char *);
static int number_from(char const *);

char const *NUMBERS[] = {
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
};

int main(void) {
    int STATUS = SUCCESS;

    fp = fopen("day01/input.txt", "r");
    if (!fp) {
        STATUS = FAILURE;
        fprintf(stderr, "Could not open the file\n");
        goto cleanup;
    }
    fseek(fp, 0, SEEK_END);
    length = ftell(fp);
    rewind(fp);

    if (!length) {
        STATUS = FAILURE;
        fprintf(stderr, "There is nothing in the file\n");
        goto cleanup;
    }

    buffer = (char *)malloc(length * sizeof(char));
    if (!buffer) {
        STATUS = FAILURE;
        fprintf(stderr, "Could not allocate a buffer\n");
        goto cleanup;
    }

    if (!fread(buffer, sizeof(char), length, fp)) {
        STATUS = FAILURE;
        fprintf(stderr, "Read nothing from the file\n");
        goto cleanup;
    }

    u64 total_part2 = 0;
    char *current = buffer;

    while (1) {
        char *next = strstr(current, "\n");
        if (!next)
            next = buffer + length;
        next -= 1;

        int line_total = converge_left(current) + converge_right(next);

        total_part2 += line_total;
        current = next + 2;

        if (current >= buffer + length)
            break;
    }

    printf("answer part 2: %ld\n", total_part2);

cleanup:
    if (buffer)
        free(buffer);

    if (fp)
        fclose(fp);

    return STATUS;
}

static u64 converge_left(char *line) {
    for (; *line != '\n'; ++line) {
        u64 number = number_from(line);
        if (number)
            return number * 10;
    }
    // this should never happen, but we dont want implicit return, hidden flow
    return 0;
}

static u64 converge_right(char *line) {
    for (; *line != '\n'; --line) {
        u64 number = number_from(line);
        if (number)
            return number;
    }
    return 0;
}

static int number_from(char const *line) {
    if (*line >= '1' && *line <= '9')
        return *line - '0';

    // 9 numbers, so we hard code it
    for (int i = 0; i < 9; ++i) {
        if (!strncmp(line, NUMBERS[i], strlen(NUMBERS[i])))
            return i + 1;
    }
    return 0;
}