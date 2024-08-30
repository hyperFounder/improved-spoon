## JumbaWall.mq5

Antes de começar, verifique o arquivo `README.md` localizado na pasta `/C Files`. Este arquivo contém informações importantes e instruções adicionais que podem ser úteis para a configuração e uso do `JumbaWall.mq5`.

### Passos de Configuração

1. Coloque o arquivo CSV que você deseja usar na pasta `/MQL5/Files` do seu diretório de dados do MetaTrader.

2. O código `JumbaWall.mq5` depende da biblioteca `DKSimplestCSVReader.mqh`. Para garantir que o código funcione corretamente, você deve incluir este arquivo na pasta `/MQL5/Include`. 

### Ajuste do Nome do Arquivo no Código

- No código `JumbaWall.mq5`, você precisa garantir que o nome do arquivo CSV especificado na variável `fileName` corresponda ao nome real do arquivo CSV que você colocou na pasta `/MQL5/Files`. 
```mql5
int OnInit() {
     string fileName = "PETR4.csv";
     .
     .
     .
     return(INIT_SUCCEEDED);
}
```
