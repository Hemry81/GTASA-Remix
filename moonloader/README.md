# SARemix Project Script Mods

## Requirements
- RTX-Remix version 0.5.4 or later
- Do not use recent builds from the Remix GitHub action

## Vehicle Toolkit

### Features

#### v0.1.2:
- Auto assign mirror material at door component (mainly for support original GTASA vehicles)
- Added Infernus wheel texture

#### v0.1.1:
- The vehicle materials now added car paint flake detail.

#### v0.1.0.c:
- Allow for view different angles when adjusting vehicle materials

#### v0.1.0.b:
- Toggle vehicle lights with "L" key

#### v0.1.0.a:
- Automatic color assignment without Remix "Terrain System"
- Automatic glass, chrome, and leather texture assignment
- Customizable materials (press "M" in car to toggle editor)
- Reveal hidden meshes due to Remix "Skip First N untexture drawcall" issue
- Automatic vehicle lights between 19:00 and 6:00

### Bug Fixes

#### v0.1.2:
- Fixed noob mistake

#### v0.1.1:
- Fixed issue where some saved materials settings were not being loaded.

#### v0.1.0.e:
- Fixed issue where saved materials settings were not being loaded.

#### v0.1.0.d:
- Fixed issue with some decal textures, such as text or logos, being disabled.

#### v0.1.0.b:
- Fixed stationary vehicle lights
- Fixed damaged headlights
- Removed Light Sphere shape for headlights

## Sun Mod

### Features

#### v0.15:
- Replace sun lighting with direct light
- Replace moon lighting with sphere light

#### v0.14:
- Brighter sun light between 12:00 to 16:00

#### v0.13:
- Smooth sun/moon transition

#### v0.12:
- Real-time sun/moon position editing (F3 hotkey)

### Fixes

#### v0.15:
- Replaced object ID with custom object for easier mesh replacement
- Potential performance improvement

#### v0.14:
- Fixed duplicate sun/moon issue

#### v0.13:
- Fixed weird night lighting

## Health Bar Mod
- Reveals original health bar hidden in Remix

## Credits
- Hemry (SARemix)
- Zeneric (custom object creation guidance, DFF, IDE, IPL, and COL files)
