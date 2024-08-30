## MQL5 Automations

#### Documentation
1. https://jumba.com.br/pro/market-gamma

### Compilação C files
- Este documento atualizado fornece instruções sobre como compilar e usar os programas `lerArquivo.c` e `textToCSV.c`, com exemplos específicos de uso.

```lerArquivo.c```
- Para compilar o programa, use o seguinte comando:
```
gcc lerArquivo.c -o lerArquivo
```
### Uso
- O programa requer dois argumentos na linha de comando: o nome do arquivo de entrada e o título do ativo a ser processado.
- Exemplo - Se você tiver um arquivo chamado jumba.txt e quiser processar informações relacionadas ao ativo PETR4, você executaria o comando abaixo:
```
./lerArquivo jumba.txt PETR4
```
- OUTPUT ```PETR4.txt```
---
```textToCSV.c```
- Para compilar o programa, use o seguinte comando:
```
gcc textToCSV.c -o textToCSV
```
### Uso
- O programa requer dois argumentos: o nome do arquivo de entrada e o nome do arquivo CSV de saída.
- Exemplo de como usar o ```textToCSV``` para converter um arquivo de texto em um arquivo CSV:
```
./textToCSV PETR4.txt PETR4.csv
```
- OUTPUT ```PETR4.csv```
