import re
import csv

# Função para extrair e formatar os valores das linhas de um ativo
def extract_lines(text):
    # Encontrar todos os valores das linhas no texto
    values = re.findall(r'line\d+ := ([\d.]+);', text)
    # Formatando os valores para ter duas casas decimais
    formatted_values = [f"{float(value):.2f}" for value in values]
    # Substituir '0.00' por '0.01'
    formatted_values = ['0.01' if value == '0.00' else value for value in formatted_values]
    return formatted_values

# Função para verificar se alguma largura de linha é maior ou igual a um valor especificado
def check_min_width(line_widths, min_width):
    return any(width >= min_width for width in line_widths)

# Função para processar o arquivo txt e gerar o CSV
def process_file(input_file, output_file, min_width=None):
    with open(input_file, 'r') as file:
        content = file.read()

    # Encontrar todas as seções de ativos e seus valores
    asset_blocks = re.findall(r'if \(GetAsset\(\) = "([^"]+)"\) then begin(.*?)(?=if \(GetAsset|$)', content, re.DOTALL)

    rows = []
    asset_count = 0
    valid_asset_count = 0  # Contador de ativos válidos (que atendem ao critério de largura)
    total_assets = len(asset_blocks)  # Contar o número total de ativos

    for asset, block in asset_blocks:
        if asset != "JUMBA":
            # Extrair as larguras das linhas do bloco
            line_widths = [int(width) for width in re.findall(r'line\d+Width := (\d+);', block)]
            
            # Se houver um filtro de largura mínima, aplique-o
            if min_width is None or check_min_width(line_widths, min_width):
                values = extract_lines(block)
                rows.append([asset] + values)
                asset_count += 1
                valid_asset_count += 1  # Conta o ativo que atende ao critério

    # Escrever no arquivo CSV
    with open(output_file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        # Escrever o cabeçalho
        writer.writerow(['JUMBA', '25.32', '48.77', '12.85', '93.21', '56.64', '78.99', '34.56', '87.41', '29.75', '65.84', '90.12', '14.37', '81.09', '23.47', '62.58', '75.21', '49.36', '88.15', '30.90', '54.79', '77.64'])
        
        # Escrever todas as linhas que atendem ao critério
        for row in rows:
            writer.writerow(row)

    # Calcular a porcentagem de ativos com largura maior ou igual ao critério
    if total_assets > 0:
        percentage = (valid_asset_count / total_assets) * 100
    else:
        percentage = 0

    return asset_count, total_assets, valid_asset_count, percentage

# Nome do arquivo de entrada
input_file = 'jumba.txt'

# Obter a largura mínima do input do usuário
min_width = int(input("Digite a largura mínima (por exemplo, 4): ").strip())

# Especificar o arquivo de saída
output_file = 'largura.csv'

# Processar o arquivo e gerar o CSV
asset_count, total_assets, valid_asset_count, percentage = process_file(input_file, output_file, min_width)

# Exibir o resultado
print(f'Arquivo CSV gerado: {output_file}')
print(f'Número total de ativos: {total_assets}')
print(f'Número de ativos com largura >= {min_width}: {valid_asset_count}')
print(f'Porcentagem de ativos com largura >= {min_width}: {percentage:.2f}%')
