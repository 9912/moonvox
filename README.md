# SunVox player bindings for LÖVE

## Requirements

Designed to run in [Love2D](https://love2d.org).
The SunVox player lib now is included. Otherwise, you can get it from [Warmplace.ru](https://warmplace.ru/soft/sunvox/) if you want update it.
Unzip the downloaded file, then place the files on their respective platforms and architectures.

## Example

See main.lua for example code.

## Notes

* Only basic functions to play songs are implemented

* The player DLL/.so is copied into the save directory upon initialization. This is required because you can't load DLLs from .love files.

* `Player:stop` stops the song, but processing for delay effects etc. continues. Call `Player:release` to completely stop and remove a song from memory; this releases the player 'slot' in the API, and makes sure no more sound is produced

* Moonvox.deinit() must be called at program exit to prevent a library crash

* Lo-fi versions are not available because LuaJIT works with SSE2 instructions onwards, no gain is achieved with these versions

* System and architecture are automatically selected

## Systems and architectures supported

- Windows
    - x86 (Intel 32bit)
    - x86_64 (Intel 64bit)
- macOS
    - arm64 (M1 Chip)
    - x86_64 (Intel 64bit)
- Linux
    - x86 (Intel 32bit)
    - x86_64 (Intel 64bit)
    - armel (Softfloat, armv7a)
    - armhf (Hardfloat, armv7a for Raspberry Pi)
    - arm64 (ARMv8 64bit)
- Android
    - x86 (Intel 32bit)
    - x86_64 (Intel 64bit)
    - armv7a (armeabi-v7a 32bit)
    - arm64 (ARMv8 64bit)

## Changelog

- v1.1: 
    - Overhaul
    - Added fixed routes inside the library file
    - Added binary files
    - SunVox DLL updated to v2.0c
    - Updated FFI code with header .h file
    - Added new functions inside Moonvox object:
        - SV_GET_MODULE_XY( in_xy, out_x, out_y ): Get module coordinates
        - SV_GET_MODULE_FINETUNE( in_finetune, out_finetune, out_relative_note ): Get module finetune
        - SV_PITCH_TO_FREQUENCY( in_pitch ): Converts pitch to frequency in Hz
        - SV_FREQUENCY_TO_PITCH( in_freq ): Converts frequency to pitch
- v1.0: 
    - Forked from megagrump's repo
    - Added windows hook in order to send him a pull request

# LICENSE

SunVox Library (modular synthesizer)  
Copyright (c) 2008 - 2019, Alexander Zolotov <nightradio@gmail.com>, WarmPlace.ru  

Original Lua code (c) 2022 megagrump (Side note: I don't know why he wiped out his repo, so I keep this fork for further upgrades), licensed under MIT license. See LICENSE file for details.
