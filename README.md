# GTASA RTX-Remix Project

Welcome to the GTASA RTX-Remix Project! This initiative aims to enhance the GTA San Andreas gaming experience by incorporating advanced RTX technology. Join our vibrant community of modders and enthusiasts as we push the boundaries of visual realism in the world of GTA San Andreas.

## Requirements

To participate in the GTASA RTX-Remix Project, please ensure you have the following:

- **GTA San Andreas Game**: A legally purchased copy of GTA San Andreas installed on your computer.
- **RTX-Compatible Graphics Card**: An NVIDIA RTX series graphics card is necessary to experience the full benefits of RTX enhancements.
- **Modding Tools**: Essential modding tools like ModLoader and MoonLoader should be installed.
- **Downgrade**: Use the [GTA: San Andreas Downgrader](http://downgraders.rockstarvision.com/) to downgrade your game to version 1.0 for optimal compatibility with RTX-Remix.
- **RTX-Remix**: Download the most recent version of RTX-Remix from the [RTX-Remix GitHub](https://github.com/NVIDIAGameWorks/rtx-remix) page. Ensure you update the "bridge-remix" and "dxvk-remix" files in the Action Tab.

  (Alternatively, use the [RTX-Remix-Downloader](https://github.com/Kowlin/RTX-Remix-Downloader/releases/latest/download/RTX.Remix.Downloader.exe) for easy downloading and updating.)

## GTASA RTX-Remix Mod Installation Guide

Enhance your GTA San Andreas by following these detailed installation steps:

### Step 1: Backup Your Game Files
Always back up your original GTA San Andreas game files before installation to safeguard your data.

### Step 2: Download and Install GitHub Desktop
1. Visit the [GitHub Desktop download page](https://desktop.github.com/).
2. Download the installer for your OS and follow the setup instructions.

### Step 3: Clone the Mod Repository
1. Open GitHub Desktop and log in.
2. Go to the mod's GitHub repository and click **Code** > **Open with GitHub Desktop**.
3. Choose **Clone** and select or create the directory `Your Game Folder\rtx-remix` for the repository.

### Step 4: Move Configuration Files
- Move the `rtx.conf` file from the `rtx-config` folder to your main game directory.

### Step 5: Install Additional Mods
- Transfer the entire `Moonloader` folder from the repository into your game directory, which includes mods like the **Sun and Moon Mod** and the **Health Bar Mod**.

### Step 6: Launch the Game and Enjoy!
- Start GTA San Andreas with RTX enhancements and enjoy the improved visuals.

# Necessary Mod List: 
To enhance stability and improve graphics quality, we recommend installing the following mods alongside our game mod:
- **Essentials Pack : [English](https://libertycity.net/files/gta-san-andreas/154094-essentials-pak-modov-pervojj.html) or [Portuguese](https://www.mixmods.com.br/2019/06/sa-essentials-pack/)** (An important mod to ensure compatibility with Remix).
- **MixSets : [English](https://www.gtainside.com/en/sanandreas/mods/138597-mixsets-v4-3/) or [Portuguese](https://www.mixmods.com.br/2022/03/sa-mixsets/)** (Fixes various issues in the original game and improve stability with Remix).
- **Improved Streaming : [Portuguese](https://www.mixmods.com.br/2022/04/improved-streaming/)** (Resolves memory streaming problems).
- **OLA – Open Limit Adjuster : [English](https://github.com/GTAmodding/III.VC.SA.LimitAdjuster/releases) or [Portuguese](https://www.mixmods.com.br/2022/10/open-limit-adjuster/)** (Resolves memory-related issues).
- **Ped Spec : [Portuguese](https://www.mixmods.com.br/2015/02/ped-spec-iluminacao-specular-nas-pessoas-como-no-mobile/)**  (Fixes mesh shaking issues).
- **ImVehFt – Improved Vehicle Features : [English](https://libertycity.net/files/gta-san-andreas/158192-improved-vehicle-features-imvehft.html) or [Portuguese](https://www.mixmods.com.br/2020/01/imvehft-improved-vehicle-features/)**.
- **VehFuncs : [English](https://libertycity.net/files/gta-san-andreas/158173-vehfuncs-v2-3-rasshirennyjj-tjuning-avto.html) or [Portuguese](https://www.mixmods.com.br/2023/01/sa-vehfuncs/)**.

**Please note that any additional mods not listed here may cause conflicts and potentially break our mod. We strongly advise against installing any other mods unless you have a thorough understanding of their compatibility and potential effects.**

# Sun Mod Requirements
This mod changes the sun and moon in GTASA using MoonLoader and Lua scripts.

**Installation** :
- **MoonLoader** : Download and install MoonLoader from the provided link. This will allow you to run Lua scripts in GTASA: [Russian](https://www.blast.hk/threads/13305/) or [English](https://gtaforums.com/topic/890987-moonloader/).
- **MoonAdditions** : Download MoonAdditions from GitHub. Copy the MoonAdditions.dll file to your MoonLoader/lib folder: [MoonAdditions](https://github.com/THE-FYP/MoonAdditions).
- **Moon ImGui** : Download and install from the provided link. Copy the "imgui.lua" and "MoonImGui.dll" files to your MoonLoader/lib folder: [Moon ImGui](https://www.blast.hk/threads/19292/).
- **SARemix_Sun** : download the "SARemix_Sun.lua" and "SARemix_Real_Sun.dat" files from the moonloader folder. Then copy it into the "game folder\MoonLoader" folder.
- **SARemix_SettingManager** : download "SARemix_SettingsManager.lua" . Then copy it into the "moonloader/lib" folder.

## Features and update (v0.1.3):
### New Feature:
**Smooth Transition:** 
- The sun and moon now move smoothly, enhancing the transition between times. This improvement applies when:
  - Loading a saved game
  - During cutscenes
  - When the player manually adjusts the time

### Fixes:
- **Weird Nighttime Lighting:** 
  Fixed an issue where the sun was still present in the game during nighttime, causing unusual lighting effects. The sun is now properly removed (culled) when it's supposed to be night.
- **Duplicate Sun and Moon:** 
  This issue has been addressed.
Fixed an issue where the sun was still present in the game during nighttime, causing unusual lighting effects. The sun is now properly removed (culled) when it's supposed to be night.

## Features and update (v0.1.2):
- Fixed interior lighting issue where there was no sun/moon light
- Resolved the problem of "hidden" shadows appearing at noon time
- real-time editing of the sun/moon position by pressing the hotkey "F3".

*(If you previously installed our sun mod CLEO script, delete it to avoid conflicts.)*

# Health Bar Mod Requirements
The Health Bar Mod is a Lua script designed to reveal the original health bar that is hidden in Remix.

**Installation** :
- **MoonLoader** : Download and install MoonLoader from the provided link. This will allow you to run Lua scripts in GTASA: [Russian](https://www.blast.hk/threads/13305/) or [English](https://gtaforums.com/topic/890987-moonloader/).
- **MoonAdditions** : Download MoonAdditions from GitHub. Copy the MoonAdditions.dll file to your MoonLoader/lib folder: [MoonAdditions](https://github.com/THE-FYP/MoonAdditions).
- **SARemix_HealthBar** : download the hbao.lua file from the moonloader folder. Then copy it into the "game folder\MoonLoader" folder.

  (If you've installed the sun mod, it means you already have moonloader and MoonAdditions installed, so there's **no need** to reinstall it.)

## Community and Contributions
We invite and appreciate contributions from the community. If you have suggestions or improvements for the GTASA RTX-Remix mod, please contribute by forking this repository, making your changes, and submitting a pull request.

## Community Guidelines
To maintain a positive and productive environment, please adhere to these guidelines:

- Respect and considerate interactions.
- Clear and concise communication.
- Refrain from spamming and off-topic posts.
- Report any issues to the moderators.

## License
The GTASA RTX-Remix Project is licensed under the MIT License. For more details, please review the license file.

## Contact and Updates
For inquiries, contact the project administrators on Discord: [Hemry](https://discordapp.com/users/hemry) or in the [GTASA Remix Discord Group](https://discord.com/channels/1028444667789967381/1097105394821759006).

Stay updated with our progress:
- **RTX-Remix Discord Channel**: [Join here](https://discord.gg/rtxremix)
- **GTASA Remix Discord Group**: [Join here](https://discord.com/channels/1028444667789967381/1097105394821759006) (Requires joining the RTX-Remix Discord channel first).

Enjoy your enhanced gameplay with the GTASA RTX-Remix Project!
