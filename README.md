## JumbaWall.mq5 e JumbaPricingPanel

- https://jumba.com.br/pro/market-gamma
- Reading CSV files doc - https://www.mql5.com/en/code/46935

![Jumba Pricing Panel](https://github.com/hyperFounder/improved-spoon/blob/main/images/jumba.png)


## JumbaPricingPanel.mq5 Configuração

1. O código `JumbaWall.mq5` e `JumbaPricingPanel.mq5` dependem da biblioteca `DKSimplestCSVReader.mqh`. Para garantir que o código funcione corretamente, você deve incluir este arquivo na pasta `/MQL5/Include`. 

2. Gere o arquivo CSV na pasta `/CSV `
```
python3 csv_script.py
```

3. Coloque o arquivo CSV que você deseja usar na pasta `/MQL5/Files` do seu diretório de dados do MetaTrader.
