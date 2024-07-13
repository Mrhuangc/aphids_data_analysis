import sys
def calculate_sequence_length_and_orientation(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            columns = line.strip().split()
            # Assuming the columns are in the order as described
            length_species_1 = int(columns[2]) - int(columns[1])
            length_species_2 = abs(int(columns[5]) - int(columns[4]))
            orientation = 1 if int(columns[4]) < int(columns[5]) else -1

            # Append the new data to the line
            new_line = line.strip() + f"\t{length_species_1}\t{length_species_2}\t{orientation}\n"
            outfile.write(new_line)

# Usage
input_file_path = sys.argv[1]
output_file_path = input_file_path + ".blocks.txt"
calculate_sequence_length_and_orientation(input_file_path, output_file_path)
