import re
import csv

# Function to extract and format the values from the lines of an asset
def extract_lines(text):
    # Find all values of the lines in the text
    values = re.findall(r'line\d+ := ([\d.]+);', text)
    # Format the values to have two decimal places
    formatted_values = [f"{float(value):.2f}" for value in values]
    # Replace '0.00' with '0.01'
    formatted_values = ['0.01' if value == '0.00' else value for value in formatted_values]
    return formatted_values

# Function to process the txt file and generate the CSV
def process_file(input_file, output_file, selected_assets=None):
    with open(input_file, 'r') as file:
        content = file.read()

    # Find all asset sections and their values
    asset_blocks = re.findall(r'if \(GetAsset\(\) = "([^"]+)"\) then begin(.*?)(?=if \(GetAsset|$)', content, re.DOTALL)

    rows = []
    for asset, block in asset_blocks:
        if asset != "JUMBA" and (selected_assets is None or asset in selected_assets):
            # Extract and format the values of the lines for other assets
            values = extract_lines(block)
            rows.append([asset] + values)

    # Write to the CSV file
    with open(output_file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        # Write the fixed JUMBA line first
        writer.writerow(['JUMBA', '25.32', '48.77', '12.85', '93.21', '56.64', '78.99', '34.56', '87.41', '29.75', '65.84', '90.12', '14.37', '81.09', '23.47', '62.58', '75.21', '49.36', '88.15', '30.90', '54.79', '77.64'])
        # Write the other lines
        for row in rows:
            writer.writerow(row)

# Input file name
input_file = 'jumba.txt'

# List of specific assets
selected_assets = [
    "ABEV3", "ASAI3", "AZUL4", "B3SA3", "BBAS3", "BBDC4", "BBSE3", "BOVA11", "BPAC11",
    "BRAP4", "BRKM5", "CMIG4", "CMIN3", "CSAN3", "ELET6", "ENGI11", "EQTL3", "GGBR4",
    "HAPV3", "HYPE3", "ITSA4", "ITUB4", "KLBN11", "LREN3", "MGLU3", "PETR4", "RADL3",
    "RAIZ4", "RENT3", "SBSP3", "SMAL11", "USIM5", "VALE3", "VBBR3", "WEGE3", "YDUQ3",
    "SUZB3", "TAEE11"
]

# Ask the user if they want to process all assets or only the selected ones
process_all = input("Deseja processar todos os ativos? (sim/não): ").strip().lower() in ['s', 'sim']

if process_all:
    output_file = 'export.csv'
    process_file(input_file, output_file)
else:
    output_file = 'export.csv'
    process_file(input_file, output_file, selected_assets)

print(f'Arquivo CSV gerado: {output_file}')
