## Setup para Usar `JumbaWall.mq5`

Antes de começar, verifique o arquivo `README.md` localizado na pasta `/C Files`. Este arquivo contém informações importantes e instruções adicionais que podem ser úteis para a configuração e uso do `JumbaWall.mq5`.

### Passos de Configuração

1. **Inclua o Arquivo CSV na Pasta Correta**
   - Coloque o arquivo CSV que você deseja usar na pasta `/MQL5/Files` do seu diretório de dados do MetaTrader. Certifique-se de que o nome do arquivo CSV corresponde ao nome especificado no código. Por exemplo, se o nome do arquivo no código é `PETR4.csv`, o arquivo CSV deve estar nomeado exatamente assim.

2. **Inclua o Arquivo `DKSimplestCSVReader.mqh`**
   - O código `JumbaWall.mq5` depende da biblioteca `DKSimplestCSVReader.mqh`. Para garantir que o código funcione corretamente, você deve incluir este arquivo na pasta `/Include` do seu diretório `/MQL5/Include`. Se você não tiver este arquivo, baixe-o do repositório e coloque-o na pasta correta.

3. **Entenda o Código**
   - O código `JumbaWall.mq5` faz o seguinte:
     - Define cores personalizadas para diferentes tipos de linhas.
     - Lê dados de um arquivo CSV, onde cada linha contém um valor e uma cor associada.
     - Plota linhas horizontais no gráfico MetaTrader com base nos valores e cores extraídos do arquivo CSV.
### Ajuste do Nome do Arquivo no Código

- No código `JumbaWall.mq5`, você precisa garantir que o nome do arquivo CSV especificado na variável `fileName` corresponda ao nome real do arquivo CSV que você colocou na pasta `/MQL5/Files`. O trecho do código que define o nome do arquivo é o seguinte:
```mql5
int OnInit() {
     string fileName = "PETR4.csv";
     .
     .
     .
     return(INIT_SUCCEEDED);
}

### Resumo das Cores Definidas

- **clWall**: `clrLime`
- **clMidWall**: `clrGray`
- **clMidWallFibo**: `clrDarkGray`
- **clFlip**: `clrYellow`
- **clMaxGamma**: `clrGreen`
- **clMinGamma**: `clrRed`
