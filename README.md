## JumbaWall.mq5 e JumbaPricingPanel

- https://jumba.com.br/pro/market-gamma
- https://www.mql5.com/en/code/46935 - Reading CSV files doc.

## JumbaWall.mq5 Configuração

1. Antes de começar, gere o arquivo CSV via JumbaWall.mq5. [README.md](https://github.com/hyperFounder/improved-spoon/tree/main/CSV).

2. Coloque o arquivo CSV que você deseja usar na pasta `/MQL5/Files` do seu diretório de dados do MetaTrader.

3. O código `JumbaWall.mq5` depende da biblioteca `DKSimplestCSVReader.mqh`. Para garantir que o código funcione corretamente, você deve incluir este arquivo na pasta `/MQL5/Include`. 

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
