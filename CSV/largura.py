import re
import sys

def find_assets_by_width(filename, min_width, show_lines=False):
    assets = {}  # Dicionário para armazenar ativos e suas larguras de linha
    current_asset = None  # Rastreamento do nome do ativo atual

    # Expressões regulares para análise
    asset_pattern = re.compile(r'if \(GetAsset\(\) = "([^"]+)"\)')
    width_pattern = re.compile(r'line(\d+)Width := (\d+);')

    # Lê o arquivo linha por linha, rastreando o número da linha se necessário
    with open(filename, 'r') as file:
        for line_num, line in enumerate(file, start=1):
            # Verifica se a linha define um ativo
            asset_match = asset_pattern.search(line)
            if asset_match:
                current_asset = asset_match.group(1)
                assets[current_asset] = []

            # Verifica se a linha define uma largura
            width_match = width_pattern.search(line)
            if width_match and current_asset is not None:
                if show_lines:
                    # Inclui o número da linha e a largura se `show_lines` for verdadeiro
                    width_value = int(width_match.group(2))
                    assets[current_asset].append((line_num, width_value))
                else:
                    # Apenas armazena a largura se `show_lines` for falso
                    width_value = int(width_match.group(2))
                    assets[current_asset].append(width_value)

    # Filtra ativos com base na largura mínima exigida
    if show_lines:
        matching_assets = {
            asset: [(line_num, width) for line_num, width in widths if width >= min_width]
            for asset, widths in assets.items() if any(width >= min_width for _, width in widths)
        }
    else:
        matching_assets = [
            asset for asset, widths in assets.items() if any(width >= min_width for width in widths)
        ]

    return matching_assets

# Exemplo de uso:
if __name__ == "__main__":
    # Verifica os argumentos de entrada
    if len(sys.argv) < 2:
        print("Uso: python find_assets.py <min_width> [--show-lines]")
        sys.exit(1)

    # Nome do arquivo definido no código
    filename = "jumba.txt"
    min_width = int(sys.argv[1])
    
    # Verifica se o usuário solicitou para mostrar as linhas
    show_lines = '--show-lines' in sys.argv

    result = find_assets_by_width(filename, min_width, show_lines)

    # Exibe o resultado com ou sem linhas
    if show_lines:
        print("Ativos com largura maior ou igual a {} e linhas correspondentes:".format(min_width))
        for asset, matches in result.items():
            print(f"Ativo: {asset}")
            for line_num, width in matches:
                print(f"  - Largura: {width} encontrada na linha {line_num}")
    else:
        print("Ativos com largura maior ou igual a {}: {}".format(min_width, result))
