import os

# Set the directory to search
dir_to_search = '.\\textures'
dir_to_save = '.\\materials'
template_file = "Material Template.txt"
search_prefix = "CJO_"
mat_prefix = "CJO_mat_"
# Create empty list to hold file names
template = []
file_names = []
# Open file for reading 
with open(template_file, 'r') as f:

    # Read all lines of file into a string
    for line in f:
        template.append(line)
        
# Loop through directory
for root, dirs, files in os.walk(dir_to_search):
    for file in files:
        name = os.path.splitext(file)[0]
        # Check if file starts with CJO_
        if name.startswith(search_prefix):
            # Add to list
            file_names.append(name)
            
for mat in file_names:
    mat_text = ""
    for line in template:
        if 'Material "hash"' in line:
            mat_text = mat_text + line.replace("hash", mat.replace(search_prefix, mat_prefix))
        elif "Looks/hash" in line:
            mat_text = mat_text + line.replace("hash", mat.replace(search_prefix, mat_prefix))
        elif "diffuse_texture" in line:
            mat_text = mat_text + line.replace("hash", mat)
        else:
            mat_text = mat_text + line
    with open(f"{dir_to_save}\\{mat.replace(search_prefix, mat_prefix)}.usda", "w") as f:
        f.write(mat_text)
        print(f"save to {dir_to_save}\{mat}.usda")