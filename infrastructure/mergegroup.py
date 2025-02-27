import os, csv, re
import numpy as np

folders = sorted(
    [f for f in os.listdir() if re.match(r"group-\d+", f)], 
    key=lambda x: int(x.split('-')[1])
)

data_matrix = []
for folder in folders:
    file_path = os.path.join(folder, "group", "results.tsv")
    if os.path.exists(file_path):
        try:
            with open(file_path, 'r') as f:
                print(f"Processing: {file_path}")
                reader = csv.reader(f, delimiter='\t')
                row = [float(x) for x in next(reader)]
                data_matrix.append(row)
        except (ValueError, StopIteration):
            continue

if data_matrix:
    np.savetxt("merged_group.tsv", np.array(data_matrix), delimiter='\t', fmt='%.15f')
    print("Matrix created successfully.")
else:
    print("No valid data found.")

