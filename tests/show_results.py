import matplotlib.pyplot as plt
from matplotlib.table import Table

OUTPUT_FILE = "output.txt"
def parse_data(output_file, table_results):
    with open(output_file, 'r') as f:
        results = f.readlines()
        for i in range(6):
            for j in range(3):
                if "200" in results[i * 3 + j] or "Connected" in results[i * 3 + j]:
                    table_results[i][j] = "Success" 
                elif "Error" in results[i * 3 + j]:
                    table_results[i][j] = "Failure"


table_results = matrix = [[0] * 3 for _ in range(6)]
parsed_data = parse_data(OUTPUT_FILE, table_results)

columns = ["Client", "KEM", "Classic Server", "Post Quantum Server", "Hybrid Server"]
data = [
    ["OpenSSL", "ECDH x25519", table_results[0][0], table_results[1][0], table_results[2][0]],
    ["OpenSSL","Kyber768", table_results[0][1], table_results[1][1], table_results[2][1]],
    ["OpenSSL", "Hybrid p521_kyber1024", table_results[0][2], table_results[1][2], table_results[2][2]],
    ["BoringSSL", "ECDH x25519", table_results[3][0], table_results[4][0], table_results[5][0]],
    ["BoringSSL", "Kyber768", table_results[3][1], table_results[4][1], table_results[5][1]],
    ["BoringSSL", "Hybrid p521_kyber1024", table_results[3][2], table_results[4][2], table_results[5][2]],
]
fig, ax = plt.subplots(figsize=(8, 8))  # Adjust the size as needed
ax.axis('off')
ax.axis('tight')
table = Table(ax, bbox=[0, 0, 1, 1])
for i, column in enumerate(columns):
    table.add_cell(0, i, width=0.25, height=0.2, text=column, loc='center', facecolor='lightgrey', fontproperties={'weight': 'bold'})
for row_index, row in enumerate(data):
    for col_index, cell in enumerate(row):
        if col_index == 0:
            table.add_cell(row_index + 1, col_index, width=0.25, height=0.2, text=cell, loc='center',  fontproperties={'weight': 'bold'})
        else:
            table.add_cell(row_index + 1, col_index, width=0.25, height=0.2, text=cell, loc='center')
for (i, j), cell in table.get_celld().items():
    if cell.get_text().get_text() == 'Success':
        cell.set_facecolor('green')
    elif cell.get_text().get_text() == 'Failure':
        cell.set_facecolor('red')
    elif cell.get_text().get_text() == 'OpenSSL':
        cell.set_facecolor('tan')
    elif cell.get_text().get_text() == 'BoringSSL':
        cell.set_facecolor('ivory')
    elif cell.get_text().get_text() == 'ECDH x25519':
        cell.set_facecolor('cornflowerblue')
    elif cell.get_text().get_text() == 'Kyber768':
        cell.set_facecolor('lavender')
    elif cell.get_text().get_text() == 'Hybrid p521_kyber1024':
        cell.set_facecolor('paleturquoise')
ax.add_table(table)
plt.title("OpenSSL client and BoringSSL client connect to 3 servers with different certificate signature and different KEM algorithms")
plt.tight_layout()
plt.show()
