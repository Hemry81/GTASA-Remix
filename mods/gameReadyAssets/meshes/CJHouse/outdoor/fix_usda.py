import os

usda_file = "./CJ_House_outdoor.usda"
usda = []
fixed_usda = ""

with open(usda_file, 'r') as f:

    # Read all lines of file into a string
    for line in f:
        usda.append(line)

i = 0
while i < len(usda):
    line = usda[i]
    if 'over "mesh"' in line:
        i += 1
        line = usda[i]
        while "                    }" not in line:
            i += 1
            line = usda[i]
    elif "prepend references = [" in line:
        i += 1
        line = usda[i]
        fixed_usda = fixed_usda + f"            prepend references = {line.replace(',','').lstrip(' ')}"
        while "]" not in line:
            i += 1
            line = usda[i]
    else:
        fixed_usda = fixed_usda + line
    i += 1
        
with open(usda_file+".test", "w") as f:
        f.write(fixed_usda)
        print(f"save to {usda_file}")