# SunVox player bindings for LÖVE

## Requirements

The SunVox player lib is not included. Get it from https://warmplace.ru/soft/sunvox/.
Unzip the downloaded file, then place the folders on their respective platforms and architectures.
Android libs are in sunvox_lib-x.y.z$.zip/sunvox_lib/android/sample_project/SunVoxLib/src/main/jniLibs/,
then, copy the contents to sunvox_lib/android folder of the repository

## Example

See main.lua for example code.

## Notes

* Only basic functions to play songs are implemented

* The player DLL/.so is copied into the save directory upon initialization. This is required because you can't load DLLs from .love files.

* `Player:stop` stops the song, but processing for delay effects etc. continues. Call `Player:release` to completely stop and remove a song from memory; this releases the player 'slot' in the API, and makes sure no more sound is produced

* Moonvox.deinit() must be called at program exit to prevent a library crash

* On _main.lua_ you must comment and uncomment lines inside `SUNVOX_PATH` to switch architectures and lo-fi version

# LICENSE

SunVox Library (modular synthesizer)  
Copyright (c) 2008 - 2019, Alexander Zolotov <nightradio@gmail.com>, WarmPlace.ru  

Lua portion of code (c) 2020 megagrump, licensed under MIT license. See LICENSE file for details.
