import re
import csv

# Função para extrair e formatar os valores das linhas de um ativo, incluindo larguras, se solicitado
def extrair_linhas_com_larguras(bloco, incluir_largura=False):
    # Extrair valores das linhas
    valores = re.findall(r'line(\d+) := ([\d.]+);', bloco)
    # Extrair larguras das linhas
    larguras = dict(re.findall(r'line(\d+)Width := (\d+);', bloco))

    # Formatar valores como tuplas (valor, largura), ou apenas valores se incluir_largura for False
    valores_formatados = []
    for numero_linha, valor in valores:
        largura = larguras.get(numero_linha)  # Obter a largura, se disponível
        # Formatar a tupla com o valor e largura como float e inteiro, se incluir_largura é True e largura existe
        if incluir_largura and largura:
            valores_formatados.append((f"{float(valor):.2f}", int(largura)))
        else:
            valores_formatados.append(f"{float(valor):.2f}")

    return valores_formatados

# Função para processar o arquivo txt e gerar o CSV
def processar_arquivo(arquivo_entrada, arquivo_saida, ativos_selecionados=None, largura_min=None, correspondencia_exata=False):
    with open(arquivo_entrada, 'r') as file:
        conteudo = file.read()

    # Encontrar todas as seções de ativos e seus valores
    blocos_ativos = re.findall(r'if \(GetAsset\(\) = "([^"]+)"\) then begin(.*?)(?=if \(GetAsset|$)', conteudo, re.DOTALL)

    linhas = []
    total_ativos = 0
    ativos_com_largura_min = 0

    for ativo, bloco in blocos_ativos:
        if ativo != "JUMBA" and (ativos_selecionados is None or ativo in ativos_selecionados):
            total_ativos += 1

            # Extrair larguras de linha do bloco
            larguras_linhas = [int(largura) for largura in re.findall(r'line\d+Width := (\d+);', bloco)]
            
            # Verificar se o ativo atende ao critério de largura mínima com base na escolha do usuário
            if largura_min is None or (
                correspondencia_exata and any(largura == largura_min for largura in larguras_linhas)
            ) or (
                not correspondencia_exata and any(largura >= largura_min for largura in larguras_linhas)
            ):
                ativos_com_largura_min += 1
                # Incluir largura nas tuplas se largura_min for especificado
                valores_com_larguras = extrair_linhas_com_larguras(bloco, incluir_largura=(largura_min is not None))
                linhas.append([ativo] + valores_com_larguras)

    # Escrever no arquivo CSV
    with open(arquivo_saida, 'w', newline='') as csvfile:
        escritor = csv.writer(csvfile)
        # Escrever um cabeçalho com nomes de linha (assumindo um máximo de 20 linhas para exemplo)
        escritor.writerow(['Ativo'] + [f'Linha{i+1}' for i in range(20)])
        # Escrever as linhas de dados dos ativos
        for linha in linhas:
            escritor.writerow(linha)

    # Imprimir informações de resumo
    print(f'Número total de ativos: {total_ativos}')
    
    # Somente exibir a contagem e porcentagem de largura mínima se o critério foi definido
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
processar_todos = input("Deseja processar todos os ativos? (yes/no): ").strip().lower() in ['y', 'yes']

# Perguntar ao usuário se deseja aplicar largura mínima
usar_largura_min = input("Deseja aplicar uma largura mínima? (yes/no): ").strip().lower() in ['y', 'yes']

if usar_largura_min:
    largura_min = int(input("Digite a largura mínima (por exemplo, 4): ").strip())
    correspondencia_exata = input("Deseja encontrar o número de ativos com largura exatamente igual a largura mínima? (yes/no): ").strip().lower() in ['y', 'yes']
else:
    largura_min = None
    correspondencia_exata = False

# Definir o arquivo de saída
arquivo_saida = 'largura.csv'
processar_arquivo(arquivo_entrada, arquivo_saida, ativos_selecionados if not processar_todos else None, largura_min, correspondencia_exata)

print(f'Arquivo CSV gerado: {arquivo_saida}')
