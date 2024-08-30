## JumbaWall.mq5

- Antes de começar, gere o arquivo CSV. [README.md](https://github.com/hyperFounder/improved-spoon/tree/main/C%20files).
- https://jumba.com.br/pro/market-gamma



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
