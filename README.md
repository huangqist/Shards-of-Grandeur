# Shards of Grandeur
Shards of Grandeur is a creature-collector RPG.  
Acquire consumable Shards in order to summon Minions in turn-based battles!  
Investigate the mystery of the Radiant Cave, which fuels all magic across the land. Take control of it before your enemies do, or you'll be wiped off the map!

## How to Install and Run
First, visit the [Releases](https://github.com/123outerme/Shards-of-Grandeur/releases) for Shards of Grandeur, and find the latest release. Scroll to the "Assets" section at the bottom of the release, and do the following, depending on your platform.  
I hope you enjoy Shards of Grandeur!

### Windows, Mac, Linux
1. Find a release `.zip` file with the name of your platform, and download it (i.e. `shards_of_grandeur_X-Y-Z_windows.zip` for Windows).
2. Once downloaded, extract the .zip file wherever you like.
3. Make sure to keep all of the game assets together in the same folder!  

To launch the game:
- Windows: Execute the `ShardsOfGrandeur.exe` file in the folder. You may be prompted by Windows Defender to declare that the game is safe to run.

- Mac: `[NEEDS CONFIRMATION]` Execute the `ShardsOfGrandeur.command` file in the folder.

- Linux: Execute `./ShardsOfGrandeur.sh`. You may first need to give this script executable permissions.

### Android
1. Find the release `.apk` file and download it to your phone.
2. Once downloaded, use a file explorer app to install the app.
3. You may be prompted by Android to scan the app. I would always recommend scanning apps not verified by Google Play.
4. Once installed, you can open the app to start playing!

## How to Build
First, I highly recommend reading [the official Godot tutorial](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html) if you have no prior experience building Godot projects. These instructions assume you are already familiar with the contents covered in the tutorial.

To build Shards of Grandeur for yourself, you need to have [Godot Engine](https://godotengine.org/) version 4.3 installed.  

1. Clone this repository to your local computer somewhere.
2. Launch Godot. Click "Import" in the Project List, and select where you saved the repository.
3. Once the project is imported, open it.
4. Select `Project > Export...` in the toolbar.
5. If you aren't exporting for Android, skip this step. Otherwise, [follow the official Godot tutorial](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html) to prepare your Android build environment.
6. Select a platform to export for, or click the Export All button at the bottom.
7. Once the export is finished, you will find the build output in the `release/` directory of the project.

Each platform binary will be built to an appropriate subdirectory (i.e. `windows` for Windows, etc.)


## LICENSE INFORMATION
The code is licensed under GPL 3.0, as found in the repository's root `LICENSE` file.   
All original artwork is provided under the CC-BY-NC-SA-4.0 License. Font file provided by fontget.com. See the `graphics/LICENSE` file for more information on these items.  
All original audio, including music and sound effects, are not licensed for general public use. See the `audio/LICENSE` file for more information.  
For all original non-code, non-audio, and non-artwork content or data, including story events, dialogue, and characters: these things are Copyright (c) 2024 Stephen Policelli.  
  
This game uses Godot Engine, available under the following license:

	Copyright (c) 2014-present Godot Engine contributors. Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
Godot is licensed under the MIT License. Please see the following URL for more details: https://godotengine.org/license/
