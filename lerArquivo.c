#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h> // Inclua este cabeçalho para isspace()

#define MAX_LINE_LENGTH 256
#define TEMP_FILE "temp_output.txt"

// Função para remover espaços à esquerda e à direita de uma string
void trimSpaces(char *str) {
    char *end;

    // Remove espaços à esquerda
    while (isspace((unsigned char)*str)) str++;

    // Se a string está vazia após remover espaços à esquerda
    if (*str == 0)
        return;

    // Remove espaços à direita
    end = str + strlen(str) - 1;
    while (end > str && isspace((unsigned char)*end)) end--;

    // Adiciona o caractere nulo ao final da string
    *(end + 1) = '\0';
}

// Função para processar o arquivo e gerar o arquivo de saída
void processFile(const char *inputFileName, const char *assetTitle) {
    FILE *inputFile = fopen(inputFileName, "r");
    FILE *outputFile = fopen(TEMP_FILE, "w");

    if (inputFile == NULL) {
        perror("Erro ao abrir o arquivo de entrada");
        exit(EXIT_FAILURE);
    }

    if (outputFile == NULL) {
        perror("Erro ao criar o arquivo de saída temporário");
        fclose(inputFile);
        exit(EXIT_FAILURE);
    }

    char line[MAX_LINE_LENGTH];
    int isProcessing = 0;

    while (fgets(line, sizeof(line), inputFile)) {
        // Verifica se a linha contém o título do ativo
        if (strstr(line, assetTitle)) {
            isProcessing = 1;
            continue;
        }

        // Verifica se chegou ao fim do bloco de informações
        if (strstr(line, "end;")) {
            isProcessing = 0;
            continue;
        }

        // Processa as linhas apenas se estivermos no bloco de informações
        if (isProcessing) {
            // Remove espaços das linhas e escreve no arquivo de saída
            trimSpaces(line);
            if (strstr(line, "line") && strstr(line, ":=")) {
                fprintf(outputFile, "%s\n", line);

                // Lê as próximas linhas para obter a cor, largura e estilo
                for (int i = 0; i < 3; i++) {
                    if (fgets(line, sizeof(line), inputFile)) {
                        trimSpaces(line);
                        if (strlen(line) > 0) {
                            fprintf(outputFile, "%s\n", line);
                        }
                    }
                }
            }
        }
    }

    fclose(inputFile);
    fclose(outputFile);

    // Define o nome do arquivo de saída baseado no assetTitle
    char outputFileName[MAX_LINE_LENGTH];
    snprintf(outputFileName, sizeof(outputFileName), "%s.txt", assetTitle);

    // Use sed para remover espaços à esquerda e à direita das linhas
    char command[MAX_LINE_LENGTH];
    snprintf(command, sizeof(command), "sed 's/^[ \t]*//;s/[ \t]*$//' %s > %s", TEMP_FILE, outputFileName);
    system(command);

    // Remove o arquivo temporário
    remove(TEMP_FILE);
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Uso: %s <input file> <asset title>\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *inputFileName = argv[1];
    const char *assetTitle = argv[2];

    processFile(inputFileName, assetTitle);

    // O nome do arquivo de saída é baseado no assetTitle
    printf("Processamento concluído. Verifique o arquivo '%s.txt'.\n", assetTitle);

    return EXIT_SUCCESS;
}
