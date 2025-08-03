**Note:** 
- Not fully tested by others. Please feel free to contact me on Discord @eldertubby.
- For context, maps by 'eldertubby' on bonk.io are made using this app.

## How to use:

To generate parkour maps on bonk.io, you'll need to

**1. Generate map data**

This is done using the parkour generator app. To use the app, you can either

- Run the ```.exe``` file by downloading the `.rar` file from [here](https://github.com/elder-tubby/bonkio-parkour-generator/releases/latest) <sub>[Recommended way for stable version]</sub> 
- Or execute the source code using the [Processing IDE](https://processing.org/download). <sub>[Not recommended since the code is updated regularly and you might run into some unfinished features]</sub>

**2. Convert that map data to bonk.io maps**

1. Install this [bonk.io mod](https://github.com/elder-tubby/bonkio-parkour-generator/blob/main/browser-script/pkrGenerator.js) on a script manager like tampermonkey.
2. Copy map data from the parkour generator app and paste it using the new mod.

**3. Confirm your graphics are accurate**

This is how everything should look like: [YouTube demo](https://www.youtube.com/watch?v=I0Nrr0XmPMA). If it doesn't, make sure you have JDK 17 installed. Or feel free to message me.

## Features:
1. Randomly generate maps based on custom factors (such as _chances of lines connecting_, _minimum distance between lines_, etc.)
2. Easily edit maps using mouse, sliders, and keyboard shortcuts.
3. Randomly assign colors to plats based on plat type and choose random background patterns.
4. Copy a player's movement path data using pkrGenerator mod and paste in generator to create death around that path.
5. Scale a map up or down.
6. Save and load presets (presets contain the values of the custom settings/factors).
7. Copy map data of any bonk map using pkrGenerator mod and edit in generator. (Circles and polygons are not supported)
8. (Technical) Directly edit map using code for full control. For example, you can select multiple lines and set all lines that are non-death and non-bouncy to no-jump. I've prepared this this [ChatGPT chat](https://chatgpt.com/share/67df6b9e-b360-8006-93af-5f8523a7d46c) to figure out the commmands.
