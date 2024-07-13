'''
Count the subfamilies of repetitive sequences
'''
import re
from sys import argv
inputfile = argv[1]
outfile = inputfile + '.RE_type.stats'

dict_type = dict()
with open(inputfile, 'r') as file:
    line = file.readlines()
    for b in line:
        b = b.strip()
        a = b.split()
        TEs = a[3]
        TEs = TEs.replace('Name=', '')
        if TEs in dict_type.keys():
            dict_type[TEs] += 1
        else:
            dict_type[TEs] = 1

with open(outfile, "w") as o:
    for i in sorted(dict_type):
        o.write(i + "\t" + str(dict_type[i]) + '\n')


