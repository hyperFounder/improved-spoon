#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_LINE_LENGTH 256
#define TEMP_FILE "temp_output.csv"

// Function to trim spaces from the start and end of a string
void trimSpaces(char *str) {
    char *end;

    // Remove leading spaces
    while (isspace((unsigned char)*str)) str++;

    // If the string is empty after removing leading spaces
    if (*str == 0)
        return;

    // Remove trailing spaces
    end = str + strlen(str) - 1;
    while (end > str && isspace((unsigned char)*end)) end--;

    // Null-terminate the string
    *(end + 1) = '\0';
}

// Function to process the file and generate the CSV output file
void processFile(const char *inputFileName, const char *outputFileName) {
    FILE *inputFile = fopen(inputFileName, "r");
    FILE *outputFile = fopen(TEMP_FILE, "w");

    if (inputFile == NULL) {
        perror("Error opening input file");
        exit(EXIT_FAILURE);
    }

    if (outputFile == NULL) {
        perror("Error creating temporary output file");
        fclose(inputFile);
        exit(EXIT_FAILURE);
    }

    char line[MAX_LINE_LENGTH];

    // Write the header of the CSV file
    fprintf(outputFile, "Value,Color\n");

    while (fgets(line, sizeof(line), inputFile)) {
        trimSpaces(line);

        // Check if the line contains data of interest
        if (strstr(line, "line") && strstr(line, ":=")) {
            // Extract the number from the line
            char *delimiter = strstr(line, ":=");
            if (delimiter) {
                delimiter += 2; // Move past ":="
                trimSpaces(delimiter);
                char *end = strchr(delimiter, ';');
                if (end) *end = '\0'; // Remove trailing ';'
                fprintf(outputFile, "%s,", delimiter);

                // Read the next lines to get the color
                for (int i = 0; i < 3; i++) {
                    if (fgets(line, sizeof(line), inputFile)) {
                        trimSpaces(line);

                        // Extract color
                        if (strstr(line, "Color :=")) {
                            delimiter = strstr(line, ":=");
                            if (delimiter) {
                                delimiter += 2;
                                trimSpaces(delimiter);
                                end = strchr(delimiter, ';');
                                if (end) *end = '\0';
                                fprintf(outputFile, "%s\n", delimiter);
                            }
                        }
                    }
                }
            }
        }
    }

    fclose(inputFile);
    fclose(outputFile);

    // Use sed to remove leading and trailing whitespaces and rename the file
    char command[MAX_LINE_LENGTH];
    snprintf(command, sizeof(command), "sed 's/^[ \t]*//;s/[ \t]*$//' %s > %s", TEMP_FILE, outputFileName);
    system(command);

    // Remove the temporary file
    remove(TEMP_FILE);
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <input file> <output CSV file>.csv\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *inputFileName = argv[1];
    const char *outputFileName = argv[2];

    processFile(inputFileName, outputFileName);

    printf("Processing completed. Check the file '%s'.\n", outputFileName);

    return EXIT_SUCCESS;
}