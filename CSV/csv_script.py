import re
import csv

# Função para extrair e formatar os valores das linhas de um ativo
def extract_lines(text):
    # Encontra todos os valores das linhas no texto
    values = re.findall(r'line\d+ := ([\d.]+);', text)
    # Formata os valores para ter duas casas decimais
    formatted_values = [f"{float(value):.2f}" for value in values]
    return formatted_values

# Função para processar o arquivo txt e gerar o CSV
def process_file(input_file, output_file, selected_assets=None):
    with open(input_file, 'r') as file:
        content = file.read()

    # Encontra todas as seções de ativos e seus valores
    asset_blocks = re.findall(r'if \(GetAsset\(\) = "([^"]+)"\) then begin(.*?)(?=if \(GetAsset|$)', content, re.DOTALL)
    
    rows = []
    for asset, block in asset_blocks:
        if selected_assets is None or asset in selected_assets:
            # Extrai e formata os valores das linhas
            values = extract_lines(block)
            # Adiciona a linha no formato desejado
            rows.append([asset] + values)

    # Grava no arquivo CSV
    with open(output_file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        for row in rows:
            writer.writerow(row)

# Nome dos arquivos de entrada
input_file = 'jumba.txt'

# Lista de ativos específicos
selected_assets = [
    "ABEV3", "ASAI3", "AZUL4", "B3SA3", "BBAS3", "BBDC4", "BBSE3", "BOVA11", "BPAC11",
    "BRAP4", "BRKM5", "CMIG4", "CMIN3", "CSAN3", "ELET6", "ENGI11", "EQTL3", "GGBR4",
    "HAPV3", "HYPE3", "ITSA4", "ITUB4", "KLBN11", "LREN3", "MGLU3", "PETR4", "RADL3",
    "RAIZ4", "RENT3", "SBSP3", "SMAL11", "SUZB3", "TAEE11", "USIM5", "VALE3", "VBBR3",
    "WEGE3", "YDUQ3"
]

# Perguntar ao usuário se deseja processar todos os ativos ou apenas os selecionados
process_all = input("Deseja processar todos os ativos? (yes/no): ").strip().lower() in ['y', 'yes']

if process_all:
    output_file = 'FULL_export_jumba.gamma.csv'
    process_file(input_file, output_file)
else:
    output_file = '38_export_jumba.gamma.csv'
    process_file(input_file, output_file, selected_assets)

print(f'Arquivo CSV gerado: {output_file}')
