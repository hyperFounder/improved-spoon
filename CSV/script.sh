#!/bin/bash

# Verifica se o número correto de argumentos foi fornecido
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <arg1>"
    exit 1
fi

# Captura o argumento fornecido
ARG1=$1

# Compila os arquivos C
gcc lerArquivo.c -o lerArquivo 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Erro: Falha ao compilar lerArquivo.c"
    exit 1
fi

gcc textToCSV.c -o textToCSV 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Erro: Falha ao compilar textToCSV.c"
    exit 1
fi

# Executa o programa lerArquivo com jumba.txt e o argumento
./lerArquivo jumba.txt "$ARG1" >/dev/null 2>&1

# Verifica se o arquivo gerado existe
if [ ! -f "${ARG1}.txt" ]; then
    echo "Erro: O arquivo ${ARG1}.txt não foi gerado."
    exit 1
fi

# Executa o programa textToCSV com o arquivo gerado e cria o CSV
./textToCSV "${ARG1}.txt" "${ARG1}.csv"

# Verifica se o arquivo CSV foi criado
if [ ! -f "${ARG1}.csv" ]; then
    echo "Erro: O arquivo ${ARG1}.csv não foi criado."
    exit 1
fi

# Limpeza: remove arquivos temporários e arquivos compilados
rm -f "${ARG1}.txt"
rm -f lerArquivo textToCSV
