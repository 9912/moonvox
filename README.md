# SunVox player bindings for LÖVE

* Requires the SunVox player library from https://warmplace.ru/soft/sunvox/

* Only basic functions to play songs are implemented

* The player DLL/.so is copied into the save directory upon initialization. This is required because you can't load DLLs from .love files.

* It's required to call `Player:release` to completely stop and remove a song from memory; this releases the player 'slot' in the API, and also makes sure the sound stops at this point. When calling `:stop` only, processing for delay effects etc. continues

* Moonvox.deinit() must be called at program exit to prevent a crash

* see main.lua for example code

# LICENSE

Powered by SunVox (modular synth & tracker)
Copyright (c) 2008 - 2020, Alexander Zolotov <nightradio@gmail.com>, WarmPlace.ru

Lua portion of code (c) 2020 megagrump, licensed under MIT license. See LICENSE for details.
