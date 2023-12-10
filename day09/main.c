#include <stdlib.h>
#include <stdio.h>
#include <memory.h>
#include <ctype.h>

typedef long i64;

static char const *const FILE_NAME = "day09/input.txt";
static char const *buffer = NULL;
static int readFile(void);

static i64 *lineToNums(char const *);
static int numberCount = 0;
i64 *const getLine(i64 const *, unsigned);
i64 lastInLine(i64 const *, unsigned);
i64 firstInLine(i64 const *, unsigned);
unsigned indexOf(unsigned, unsigned);

int main(void) {
    int status = EXIT_SUCCESS;
    if (!readFile()) {
        status = EXIT_FAILURE;
        goto cleanup;
    }

    i64 part1 = 0, part2 = 0;
    char *currentLine = (char*)buffer;
    for (;;) {
        char const *const nextStartIdx = strstr(currentLine, "\n");

        i64 *numbers = lineToNums(currentLine);
        if (!numbers) {
            status = EXIT_FAILURE;
            goto cleanup;
        }

        // fill in the differences
        for (unsigned lineCounter = 1; lineCounter < numberCount; ++lineCounter) {
            unsigned lineSize = numberCount - lineCounter;
            for (unsigned column = 0; column < lineSize; ++column) {
                unsigned currentNumberIndex = indexOf(lineCounter, column);
                // difference
                numbers[currentNumberIndex] = numbers[indexOf(lineCounter - 1, column + 1)] - numbers[indexOf(lineCounter - 1, column)];
            }
        }

        i64 p1_delta = 0, p2_delta = 0;
        unsigned keyNumber = 0;
        for (unsigned i = 0; i < numberCount; ++i) {
            i64 number = numbers[indexOf(i, 0)];
            for (unsigned j = 1; j < numberCount - i; ++j) {
                if (numbers[indexOf(i, j)] != number)
                    goto nextIteration;
				}
			keyNumber = i;
			goto exit_loop;

        nextIteration:
			__asm __volatile("nop");
        }
    exit_loop:
        // part 1:
        for (int i = numberCount - 1; i >= 0; --i) {
            i64 lastItem = lastInLine(numbers, i);
            p1_delta += lastItem;
        }

        // part 2:
        for (int i = keyNumber; i >= 0; --i)
            p2_delta = firstInLine(numbers, i) - p2_delta;

        part1 += p1_delta;
        part2 += p2_delta;

#ifdef _DEBUG
	for (unsigned i = 0; i < numberCount; ++i) {
		if (i == keyNumber)
			fprintf(stderr, "key: ");
		for (unsigned j = 0; j < numberCount - i; ++j) {
			fprintf(stderr, "%ld ", numbers[indexOf(i, j)]);
		}
		puts("");
	}

	fprintf(stderr, "back: %ld, forward: %ld\n", p2_delta, p1_delta);
#endif



        free(numbers);

        if (!nextStartIdx)
            break;
        currentLine = (char*)nextStartIdx + 1;
    }

    // display answer:
    fprintf(stderr, "part 1: %ld\npart 2: %ld\n", part1, part2);

cleanup:
    if (buffer)
        free((void*)buffer);

    return status;
}

static i64 *lineToNums(char const *line) {
    char const *original = line;

    i64 *numbers = NULL;
    numberCount = 0;

    for (;;) {
        if (isdigit(*line) || *line == '-') {
            do
                ++line;
            while (isdigit(*line));

            ++numberCount;
        }
        if (*line == '\n' || *line == 0)
            break;

        ++line;
    }
    numbers = (i64 *)malloc((((numberCount + 1) * numberCount) >> 1) * sizeof(i64));
    if (!numbers)
        return NULL;

    line = original;
    int idx = 0;
    for (;;) {
        if (isdigit(*line) || *line == '-') {
            // i64 number = *line - 0x30;
            i64 number = 0;
            sscanf(line, "%ld", &number);
			do
                ++line;
            while (isdigit(*line));

            numbers[idx] = number;
            ++idx;
        }
        if (*line == '\n' || *line == 0)
            break;

        ++line;
    }

    return numbers;
}

static int readFile(void) {
    int status = 1;
    FILE *fp = NULL;

    fp = fopen(FILE_NAME, "r");
    if (!fp) {
        status = 0;
        goto cleanup;
    }

    fseek(fp, 0, SEEK_END);
    unsigned length = ftell(fp);
    rewind(fp);

    if (!length) {
        status = 0;
        goto cleanup;
    }

    buffer = (char *)malloc(length * sizeof(char));
    if (!buffer) {
        status = 0;
        goto cleanup;
    }

    unsigned _read = fread((void *)buffer, 1, length, fp);
#pragma unused(_read)

cleanup:
    if (fp)
        fclose(fp);

    return status;
}

unsigned startOfLine(unsigned lineNumber) {
    return (((numberCount + 1) * numberCount) >> 1) - (((numberCount - lineNumber + 1) * (numberCount - lineNumber)) >> 1);
}

unsigned indexOf(unsigned lineNumber, unsigned column) {
    return startOfLine(lineNumber) + column;
}

i64 *const getLine(i64 const *numbers, unsigned lineNumber) {
    const unsigned startOfLineIndex = startOfLine(lineNumber);
    return numbers + startOfLineIndex;
}

i64 lastInLine(i64 const *numbers, unsigned lineNumber) {
    i64 const *currentLine = getLine(numbers, lineNumber);
    return currentLine[numberCount - lineNumber - 1];
}

i64 firstInLine(i64 const *numbers, unsigned lineNumber) {
    i64 const *currentLine = getLine(numbers, lineNumber);
    return currentLine[0];
}
