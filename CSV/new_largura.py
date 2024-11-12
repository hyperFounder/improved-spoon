import re
import csv

# Função para extrair e filtrar os valores de um ativo com base na largura mínima
def extrair_linhas_com_largura_min(bloco, largura_min=None, correspondencia_exata=False):
    # Extrair valores das linhas
    valores = re.findall(r'line(\d+) := ([\d.]+);', bloco)

    # Extrair larguras das linhas
    larguras = dict(re.findall(r'line(\d+)Width := (\d+);', bloco))

    # Armazenar somente valores que atendem ao critério de largura mínima
    valores_filtrados = []
    for numero_linha, valor in valores:
        # Formatar valores para duas casas decimais e substituir '0.00' por '0.01'
        valor_formatado = f"{float(valor):.2f}"
        if valor_formatado == '0.00':
            valor_formatado = '0.01'
        
        # Obter largura da linha
        largura = int(larguras.get(numero_linha, 0))  # Largura padrão é 0 se não especificada

        # Aplicar o filtro de largura mínima
        if largura_min is None or (
            correspondencia_exata and largura == largura_min
        ) or (
            not correspondencia_exata and largura >= largura_min
        ):
            valores_filtrados.append(valor_formatado)

    # Adicionar os últimos três valores da linha (sem filtro de largura)
    ultimos_tres_valores = [f"{float(valor):.2f}" for _, valor in valores[-3:]]
    valores_filtrados.extend(ultimos_tres_valores)

    return valores_filtrados

# Função para processar o arquivo e gerar o CSV
def processar_arquivo(arquivo_entrada, arquivo_saida, ativos_selecionados=None, largura_min=None, correspondencia_exata=False):
    with open(arquivo_entrada, 'r') as file:
        conteudo = file.read()

    # Encontrar todas as seções de ativos e seus valores
    blocos_ativos = re.findall(r'if \(GetAsset\(\) = "([^"]+)"\) then begin(.*?)(?=if \(GetAsset|$)', conteudo, re.DOTALL)

    linhas = []
    total_ativos = 0
    ativos_com_largura_min = 0

    # Sempre adicionar "JUMBA" com valores fixos
    jumba = ["JUMBA", "25.32", "48.77", "12.85", "93.21", "56.64", "78.99", "34.56", "87.41", "29.75", "65.84", "90.12", 
             "14.37", "81.09", "23.47", "62.58", "75.21", "49.36", "88.15", "30.90", "54.79", "77.64"]
    linhas.append(jumba)

    for ativo, bloco in blocos_ativos:
        if ativo != "JUMBA" and (ativos_selecionados is None or ativo in ativos_selecionados):
            total_ativos += 1

            # Extrair valores atendendo ao critério de largura mínima e adicionar os três últimos valores
            valores_com_largura_min = extrair_linhas_com_largura_min(bloco, largura_min, correspondencia_exata)

            # Se houver valores que atendem ao critério de largura mínima, adicionar o ativo e seus valores
            if valores_com_largura_min:
                ativos_com_largura_min += 1
                linhas.append([ativo] + valores_com_largura_min)

    # Escrever no arquivo CSV
    with open(arquivo_saida, 'w', newline='') as csvfile:
        escritor = csv.writer(csvfile)
        # Não escrever cabeçalho, apenas os dados
        for linha in linhas:
            escritor.writerow(linha)

    # Imprimir informações de resumo
    print(f'Número total de ativos: {total_ativos}')
    
    # Exibir o número de ativos com largura mínima e a porcentagem, se definido
    if largura_min is not None:
        porcentagem_largura_min = (ativos_com_largura_min / total_ativos) * 100 if total_ativos > 0 else 0
        print(f'Número de ativos com largura {"=" if correspondencia_exata else ">="} {largura_min}: {ativos_com_largura_min}')
        print(f'Porcentagem de ativos com largura {"=" if correspondencia_exata else ">="} {largura_min}: {porcentagem_largura_min:.2f}%')

# Arquivo de entrada
arquivo_entrada = 'jumba.txt'

# Lista de ativos específicos
ativos_selecionados = [
    "ABEV3", "ASAI3", "AZUL4", "B3SA3", "BBAS3", "BBDC4", "BBSE3", "BOVA11", "BPAC11",
    "BRAP4", "BRKM5", "CMIG4", "CMIN3", "CSAN3", "ELET6", "ENGI11", "EQTL3", "GGBR4",
    "HAPV3", "HYPE3", "ITSA4", "ITUB4", "KLBN11", "LREN3", "MGLU3", "PETR4", "RADL3",
    "RAIZ4", "RENT3", "SBSP3", "SMAL11", "USIM5", "VALE3", "VBBR3", "WEGE3", "YDUQ3",
    "SUZB3", "TAEE11"
]

# Perguntar ao usuário se deseja processar todos os ativos ou apenas os selecionados
processar_todos = input("Deseja processar todos os ativos? (sim/não): ").strip().lower() in ['s', 'sim']

# Perguntar ao usuário se deseja aplicar uma largura mínima
usar_largura_min = input("Deseja aplicar uma largura mínima? (sim/não): ").strip().lower() in ['s', 'sim']

if usar_largura_min:
    largura_min = int(input("Digite a largura mínima (por exemplo, 4): ").strip())
    correspondencia_exata = input("Deseja encontrar o número de ativos com largura exatamente igual à largura mínima? (sim/não): ").strip().lower() in ['s', 'sim']
else:
    largura_min = None
    correspondencia_exata = False

# Definir o arquivo de saída
arquivo_saida = 'largura.csv'
processar_arquivo(arquivo_entrada, arquivo_saida, ativos_selecionados if not processar_todos else None, largura_min, correspondencia_exata)

print(f'Arquivo CSV gerado: {arquivo_saida}')
