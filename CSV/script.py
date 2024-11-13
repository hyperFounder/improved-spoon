import subprocess
import csv
import os

# Função para executar o script largura.py para gerar o arquivo largura.csv
def executar_largura_py():
    try:
        # Executar o script largura.py usando subprocess
        subprocess.run(['python3', 'largura.py'], check=True)
        print("largura.py executado com sucesso.")
    except subprocess.CalledProcessError as e:
        print(f"Erro ao executar o largura.py: {e}")
        exit(1)

# Função para executar o script csv_script.py no diretório Old files
def executar_csv_script_py():
    try:
        # Executar o script csv_script.py usando subprocess
        subprocess.run(['python3', 'Old files/csv_script.py'], check=True)
        print("csv_script.py executado com sucesso.")
    except subprocess.CalledProcessError as e:
        print(f"Erro ao executar o csv_script.py: {e}")
        exit(1)

# Etapa 2: Ler o arquivo largura.csv, substituir 0.00 por 0.01
def modificar_largura_csv():
    try:
        with open('largura.csv', 'r', newline='') as infile:
            leitor = csv.reader(infile)
            linhas = []

            for linha in leitor:
                # Substituir qualquer valor 0.00 por 0.01
                linha_atualizada = ['0.01' if valor == '0.00' else valor for valor in linha]
                linhas.append(linha_atualizada)

        # Etapa 3: Escrever as linhas modificadas no arquivo export.csv
        with open('export.csv', 'w', newline='') as outfile:
            escritor = csv.writer(outfile)
            escritor.writerows(linhas)

        print("O arquivo export.csv foi criado com os valores modificados.")

        # Apagar o arquivo largura.csv após gerar o export.csv
        if os.path.exists('largura.csv'):
            os.remove('largura.csv')
            print("O arquivo largura.csv foi excluído com sucesso.")
        else:
            print("O arquivo largura.csv não foi encontrado para excluir.")

    except FileNotFoundError:
        print("O arquivo 'largura.csv' não foi encontrado. Por favor, certifique-se de que o largura.py foi executado com sucesso.")
        exit(1)
    except Exception as e:
        print(f"Ocorreu um erro ao modificar o CSV: {e}")
        exit(1)

# Função principal para orquestrar as etapas
def principal():
    # Perguntar ao usuário se deseja aplicar largura
    aplicar_largura = input("Deseja aplicar o filtro de largura exata? (sim/não): ").strip().lower()

    # Verificar resposta do usuário e executar o script correspondente
    if aplicar_largura in ['sim', 's']:
        executar_largura_py()
        # Modificar o largura.csv e salvar no export.csv
        modificar_largura_csv()
    else:
        executar_csv_script_py()

# Executar a função principal
if __name__ == "__main__":
    principal()
