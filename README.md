**Note:** 
- Not fully tested by others. Please feel free to contact me on Discord @eldertubby.
- For context, maps by 'eldertubby' on bonk.io are made using this app.

## How to use:

To generate parkour maps on bonk.io, you'll need to

### 1. Generate map data

This is done using the parkour generator app. To use the app, you can either

- Download the .exe file
- Or execute the source code using the [Processing IDE](https://processing.org/download).

### 2. Convert that map data to bonk.io maps

1. Install this [bonk.io mod](https://github.com/elder-tubby/parkour-gen-browser-script/blob/main/mini-script.js) on a script manager like tampermonkey.
2. Copy map data from the parkour generator app and paste it using the new mod.


## Features.
1. Randomly generate maps based on custom factors (such as _chances of lines connecting_, _minimum distance between lines_, etc.)
2. Easily edit maps using mouse (dragging, selecting, etc.), sliders (for stuff plat width, angle, etc.), and keyboard shortcuts.
3. Randomly assign colors to plats (based on plat type) and choose a random background pattern.
4. Copy a player's movement path data (using pkrGenerator mod) and paste in generator to create death around that path.
5. Scale a map up or down.
6. Save and load presets (presets contain the values of the custom settings/factors).
7. Copy map data of any bonk map (using pkrGenerator mod) and edit in geneartor. (Circles and polygons are not supported)
8. (Technical) Directly edit map using code for full control. For example, you can select multiple lines and set all lines that are non-death and non-bouncy to no-jump. I'd recommend using this [ChatGPT chat](https://chatgpt.com/share/67df6b9e-b360-8006-93af-5f8523a7d46c) to figure out the commmands.
