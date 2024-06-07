import matplotlib.pyplot as plt
from matplotlib.table import Table

OUTPUT_FILE = "output.txt"
def parse_data(output_file):
    with open(output_file) as f:
        pass

parsed_data = parse_data(OUTPUT_FILE)   

columns = ["Client", "KEM", "Classic Server", "Post Quantum Server", "Hybrid Server"]
data = [
    ["OpenSSL", "ECDH x25519", "", "", ""],
    ["OpenSSL","Kyber768", "", "", ""],
    ["OpenSSL", "Hybrid p521_kyber1024", "", "", ""],
    ["BoringSSL", "ECDH x25519", "", "", ""],
    ["BoringSSL", "Kyber768", "", "", ""],
    ["BoringSSL", "Hybrid p521_kyber1024", "", "", ""],
]
fig, ax = plt.subplots(figsize=(8, 8))  # Adjust the size as needed
ax.axis('off')
ax.axis('tight')
table = Table(ax, bbox=[0, 0, 1, 1])
for i, column in enumerate(columns):
    table.add_cell(0, i, width=0.25, height=0.2, text=column, loc='center', facecolor='lightgrey', fontproperties={'weight': 'bold'})
for row_index, row in enumerate(data):
    for col_index, cell in enumerate(row):
        table.add_cell(row_index + 1, col_index, width=0.25, height=0.2, text=cell, loc='center')
ax.add_table(table)
plt.tight_layout()
plt.show()
