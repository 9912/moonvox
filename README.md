# SunVox player bindings for LÖVE

## Requirements

The SunVox player lib is not included. Get it from https://warmplace.ru/soft/sunvox/.

## Example

See main.lua for example code.

## Notes

* Only basic functions to play songs are implemented

* The player DLL/.so is copied into the save directory upon initialization. This is required because you can't load DLLs from .love files.

* `Player:stop` stops the song, but processing for delay effects etc. continues. Call `Player:release` to completely stop and remove a song from memory; this releases the player 'slot' in the API, and makes sure no more sound is produced

* Moonvox.deinit() must be called at program exit to prevent a library crash

# LICENSE

Powered by SunVox (modular synth & tracker)
Copyright (c) 2008 - 2020, Alexander Zolotov <nightradio@gmail.com>, WarmPlace.ru

Lua portion of code (c) 2020 megagrump, licensed under MIT license. See LICENSE for details.
