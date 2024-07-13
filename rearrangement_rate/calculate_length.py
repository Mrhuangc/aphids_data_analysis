# -*- coding: utf-8 -*-
import sys
def calculate_total_length(segments):
    total_length = 0
    last_end = 0

    for start, end in segments:
        # If the current segment overlaps with the previous segment, adjust the starting position
        start = max(start, last_end + 1)

        # Accumulate the length of the current segment if it starts after the end of the previous segment
        if start <= end and end > last_end:
            total_length += end - start + 1
            #print(start, end, last_end)

        # Update the end position of the previous segment
        last_end = max(last_end, end)

    return total_length

def process_data(data):
    segments = {}
    for line in data:
        parts = line.strip().split('\t')
        chrom = parts[0]
        start = int(parts[1])
        end = int(parts[2])

        if chrom not in segments:
            segments[chrom] = []

        segments[chrom].append((start, end))

    total_lengths = {}
    for chrom, segment_list in segments.items():
        segment_list.sort()  # Sort by starting position
        total_lengths[chrom] = calculate_total_length(segment_list)

    return total_lengths

if __name__ == "__main__":
    file_path = sys.argv[1]

    with open(file_path, 'r') as file:
        data = file.readlines()

    total_length = 0
    chrom_lengths = process_data(data)
    for chrom, length in sorted(chrom_lengths.items()):
        total_length += length
        print("{}: {}".format(chrom, length))
print("total_length: ",total_length)
