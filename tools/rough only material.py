# GTASA Remix Rough and Normal Material Generator by Discord Hemry.
# Do not edit any line unless you understand its purpose.
# Place this script to "your game folder/rtx-remix" folder

import os
import shutil
from pathlib import Path

dirname = os.path.dirname(__file__)
capture_directory = './captures/textures'
newtex_dirctory = './new_tex'
modscapture_directory = './mods/gameReadyAssets/capture/textures'
output_file = './mods/gameReadyAssets/rough_only.usda'
ignoreFiles = ['T_SkyProbe_NonReplaceable.dds']
diff_file_path = "./diff_file.data"
importHashfromFile = "./diff_file.data"
dev_mode = False

base_data = [
'#usda 1.0\n',
'(\n',
'    customLayerData = {\n',
'        dictionary omni_layer = {\n',
'            dictionary muteness = {\n',
'            }\n',
'        }\n',
'    }\n',
'    upAxis = "Z"\n',
')\n',
'def "RootNode"\n',
'{\n',
'    def "Looks"\n',
'    {\n'
]
close_para = [
'    }\n',
'}'
]
mat_albedo = [
'        {\n',
'            over "Shader"\n',
'            {\n',
'                asset inputs:diffuse_texture = @../../captures/textures/{$texture}.dds@ (\n',
'                    customData = {\n',
'                        asset default = @@\n',
'                    }\n',
'                    displayGroup = "Diffuse"\n',
'                    displayName = "Albedo Map"\n',
'                    doc = "The texture specifying the albedo value and the optional opacity value to use in the alpha channel"\n',
'                    hidden = false\n',
'                )\n'
]
mat_rough = [
'                asset inputs:normalmap_texture = @./texture/normal.dds@ (\n',
'                    colorSpace = "auto"\n',
'                    customData = {\n',
'                        asset default = @@\n',
'                    }\n',
'                    displayGroup = "Normal"\n',
'                    displayName = "Normal Map"\n',
'                    hidden = false\n',
'                )\n',
'                float inputs:reflection_roughness_constant = 0.5\n',
'                asset inputs:reflectionroughness_texture = @./texture/rough.dds@ (\n',
'                    colorSpace = "auto"\n',
'                    customData = {\n',
'                        asset default = @@\n',
'                    }\n',
'                    displayGroup = "Specular"\n',
'                    displayName = "Roughness Map"\n',
'                    hidden = false\n',
'                )\n',
'            }\n',
'        }\n'
]

def make_usda(materials):
    usda = []
    for data in base_data:
        usda.append(data)
    i = 0
    for mat in materials:
        usda.append(mat)
        for data in materials[mat]:
            usda.append(data)
        i += 1
    for data in close_para:
        usda.append(data)
    return usda
    
def make_mat(ddsfiles):
    mat = {}
    for file in ddsfiles:
        if file != "":
            mathash = f'        over "mat_{file}"\n'
            mat[mathash] = []
            for data in mat_albedo:
                mat[mathash].append(data.replace("{$texture}", file))
            for data in mat_rough:
                mat[mathash].append(data)
        
    return mat

def merge_usda(new):
    diff = ""
    newcapture = []
    origin = {}
    lines = ""
    
    if os.path.exists(output_file):
        with open(output_file, "r") as file:
            lines = file.readlines()
    i = 0
    while i < len(lines):
        line = lines[i]
        if '        over "mat_' in line:
            hash = line
            origin[hash] = []
            i += 1
            line = lines[i]
            while line.rstrip(" ") != '        }\n':
                origin[hash].append(line)
                i += 1
                if i < len(lines):
                    line = lines[i]
                else:
                    break
            origin[hash].append('        }\n')
        i += 1
    diff_data = joinRelativePath(dirname, diff_file_path)
    diff_file = []
    if os.path.exists(diff_data):
        with open(diff_data, "r") as file:
            diff_file = file.read().split(", ")
            
    # Compare Captures Texture
    for mat in new:
        try:
            isinstance(origin[mat], list)
        except:
            hash = mat.replace('        over "mat_', '').replace('"\n', '').rstrip(" ")
            if hash not in diff_file:
                diff += hash + ", "
                newcapture.append(hash)

    # Compare texture in "rough_only.usda"
    for mat in origin:
        try:
            isinstance(new[mat], list)
        except:
            new[mat] = origin[mat]
    
    with open(diff_data, "a") as file:
        file.writelines(diff)
        
    # copy new capture texture
    
    try:
        os.makedirs(newtex_dirctory)
    except FileExistsError:
        # directory already exists
        pass
    for mat in newcapture:
        capture_file = os.path.join(modscapture_directory, mat + ".dds")
        if not os.path.exists(capture_file):
            src = os.path.join(capture_directory, mat + ".dds")
            dst = os.path.join(newtex_dirctory, mat + ".dds")
            if dev_mode:
                shutil.copy(src, capture_file)
            else:
                shutil.copy(src, dst)
        
    return new

def joinRelativePath(path, relativepath):
    p = path.split("\\")
    if "../" in relativepath:
        r = relativepath.replace("//", "/").split("../")
        path = ""
        for i in range(len(p)-len(r)):
            if path == "":
                path = p[i]
            else:
                path = path + "/" + p[i]
        path = path + "/"
        for i in range(len(r)):
            path = path + r[i]
    elif "./" in relativepath:
        path = path.replace("\\", "/") + relativepath.replace("//", "/").replace("./", "/")
        
    return path

capture_directory = joinRelativePath(dirname, capture_directory)
newtex_dirctory = joinRelativePath(dirname, newtex_dirctory)
modscapture_directory = joinRelativePath(dirname, modscapture_directory)
output_file = joinRelativePath(dirname, output_file)
file_names = []
importedhash = []
materials = {}

for file in os.listdir(capture_directory):
    if file.endswith('.dds'):
        if file not in ignoreFiles:
            file_names.append(file.replace('.dds', ''))


if importHashfromFile != "":
    importHashfromFile = joinRelativePath(dirname, importHashfromFile)
    if os.path.exists(importHashfromFile):
        with open(importHashfromFile, "r") as file:
            importedhash = file.read().split(", ")
file_names = list(set(file_names + importedhash))

materials = make_mat(file_names)
materials = merge_usda(materials)
usda_file = make_usda(materials)
try:
    with open(output_file, "w") as file:
        file.writelines(usda_file)    
    print("File saved as", output_file)
except:
    print("Failed to save file", output_file)