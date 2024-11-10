Uso:
  python find_assets.py <min_width> [--show-lines]

Descrição:
  Este script encontra e exibe os nomes dos ativos no arquivo "jumba.txt" que possuem larguras maiores ou iguais a <min_width>.
  
  O arquivo "jumba.txt" deve estar no mesmo diretório do script.

Argumentos:
  <min_width>      Especifica a largura mínima para a filtragem dos ativos.

Opções:
  --show-lines     Opcional. Se incluído, o script também exibirá os números das linhas em que as larguras foram encontradas.

Exemplos:
  1. Para encontrar ativos com largura maior ou igual a 2 (sem mostrar as linhas):
     python find_assets.py 2

  2. Para encontrar ativos com largura maior ou igual a 2 e exibir os números das linhas:
     python find_assets.py 2 --show-lines
