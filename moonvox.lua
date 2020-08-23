--[[
LuaJIT bindings for SunVox
Copyright 2020 megagrump@pm.me

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

local ffi = require('ffi')
local ls = require('love.system')

ffi.cdef([[
/*
	SunVox Library (modular synthesizer)
	Copyright (c) 2008 - 2019, Alexander Zolotov <nightradio@gmail.com>, WarmPlace.ru

	Modified for use with the LuaJIT FFI by megagrump@pm.me

	Requires SunVox Library v1.9.5d
	See sunvox_lib/headers/sunvox.h for function documentation
*/

/*
   Constants, data types and macros
*/
enum {
	NOTECMD_NOTE_OFF = 128,
	NOTECMD_ALL_NOTES_OFF = 129, /* send "note off" to all modules */
	NOTECMD_CLEAN_SYNTHS = 130, /* put all modules into standby state (stop and clear all internal buffers) */
	NOTECMD_STOP = 131,
	NOTECMD_PLAY = 132,
	NOTECMD_SET_PITCH = 133, /* set pitch ctl_val */
};

typedef struct
{
	uint8_t note;           /* NN: 0 - nothing; 1..127 - note num; 128 - note off; 129, 130... - see NOTECMD_xxx defines */
	uint8_t vel;            /* VV: Velocity 1..129; 0 - default */
	uint16_t module;        /* MM: 0 - nothing; 1..65535 - module number + 1 */
	uint16_t ctl;           /* 0xCCEE: CC: 1..127 - controller number + 1; EE - effect */
	uint16_t ctl_val;       /* 0xXXYY: value of controller or effect */
} sunvox_note;

/* Flags for sv_init(): */
enum {
	SV_INIT_FLAG_NO_DEBUG_OUTPUT = ( 1 << 0 ),
	SV_INIT_FLAG_USER_AUDIO_CALLBACK = ( 1 << 1 ), /* Offline mode: */
	                                               /* system-dependent audio stream will not be created; */
	                                               /* user calls sv_audio_callback() to get the next piece of sound stream */
	SV_INIT_FLAG_OFFLINE = ( 1 << 1 ),             /* Same as SV_INIT_FLAG_USER_AUDIO_CALLBACK */
	SV_INIT_FLAG_AUDIO_INT16 = ( 1 << 2 ),         /* Desired sample type of the output sound stream : int16_t */
	SV_INIT_FLAG_AUDIO_FLOAT32 = ( 1 << 3 ),       /* Desired sample type of the output sound stream : float */
	                                               /* The actual sample type may be different, if SV_INIT_FLAG_USER_AUDIO_CALLBACK is not set */
	SV_INIT_FLAG_ONE_THREAD = ( 1 << 4 ),          /* Audio callback and song modification are in single thread */
	                                               /* Use it with SV_INIT_FLAG_USER_AUDIO_CALLBACK only */
};

/* Flags for sv_get_time_map(): */
enum {
	SV_TIME_MAP_SPEED = 0,
	SV_TIME_MAP_FRAMECNT = 1,
	SV_TIME_MAP_TYPE_MASK = 3,
};

/* Flags for sv_get_module_flags(): */
enum {
	SV_MODULE_FLAG_EXISTS = ( 1 << 0 ),
	SV_MODULE_FLAG_EFFECT = ( 1 << 1 ),
	SV_MODULE_FLAG_MUTE = ( 1 << 2 ),
	SV_MODULE_FLAG_SOLO = ( 1 << 3 ),
	SV_MODULE_FLAG_BYPASS = ( 1 << 4 ),
	SV_MODULE_INPUTS_OFF = 16,
	SV_MODULE_INPUTS_MASK = ( 255 << 16 ),
	SV_MODULE_OUTPUTS_OFF = ( 16 + 8 ),
	SV_MODULE_OUTPUTS_MASK = ( 255 << (16 + 8) ),
};

/* DYNAMIC LIBRARY (DLL, SO, etc.) ... */

int sv_audio_callback( void* buf, int frames, int latency, uint32_t out_time );
int sv_audio_callback2( void* buf, int frames, int latency, uint32_t out_time, int in_type, int in_channels, void* in_buf );
int sv_open_slot( int slot );
int sv_close_slot( int slot );
int sv_lock_slot( int slot );
int sv_unlock_slot( int slot );
int sv_init( const char* config, int freq, int channels, uint32_t flags );
int sv_deinit( void );
int sv_get_sample_rate( void );
int sv_update_input( void );
int sv_load( int slot, const char* name );
int sv_load_from_memory( int slot, void* data, uint32_t data_size );
int sv_play( int slot );
int sv_play_from_beginning( int slot );
int sv_stop( int slot );
int sv_set_autostop( int slot, int autostop );
int sv_get_autostop( int slot );
int sv_end_of_song( int slot );
int sv_rewind( int slot, int t );
int sv_volume( int slot, int vol );
int sv_set_event_t( int slot, int set, int t );
int sv_send_event( int slot, int track_num, int note, int vel, int module, int ctl, int ctl_val );
int sv_get_current_line( int slot );
int sv_get_current_line2( int slot );
int sv_get_current_signal_level( int slot, int channel );
const char* sv_get_song_name( int slot );
int sv_get_song_bpm( int slot );
int sv_get_song_tpl( int slot );
uint32_t sv_get_song_length_frames( int slot );
uint32_t sv_get_song_length_lines( int slot );
int sv_get_time_map( int slot, int start_line, int len, uint32_t* dest, int flags );
int sv_new_module( int slot, const char* type, const char* name, int x, int y, int z );
int sv_remove_module( int slot, int mod_num );
int sv_connect_module( int slot, int source, int destination );
int sv_disconnect_module( int slot, int source, int destination );
int sv_load_module( int slot, const char* file_name, int x, int y, int z );
int sv_load_module_from_memory( int slot, void* data, uint32_t data_size, int x, int y, int z );
int sv_sampler_load( int slot, int sampler_module, const char* file_name, int sample_slot );
int sv_sampler_load_from_memory( int slot, int sampler_module, void* data, uint32_t data_size, int sample_slot );
int sv_get_number_of_modules( int slot );
int sv_find_module( int slot, const char* name );
uint32_t sv_get_module_flags( int slot, int mod_num );
int* sv_get_module_inputs( int slot, int mod_num );
int* sv_get_module_outputs( int slot, int mod_num );
const char* sv_get_module_name( int slot, int mod_num );
uint32_t sv_get_module_xy( int slot, int mod_num );
int sv_get_module_color( int slot, int mod_num );
uint32_t sv_get_module_finetune( int slot, int mod_num );
uint32_t sv_get_module_scope2( int slot, int mod_num, int channel, int16_t* dest_buf, uint32_t samples_to_read );
int sv_module_curve( int slot, int mod_num, int curve_num, float* data, int len, int w );
int sv_get_number_of_module_ctls( int slot, int mod_num );
const char* sv_get_module_ctl_name( int slot, int mod_num, int ctl_num );
int sv_get_module_ctl_value( int slot, int mod_num, int ctl_num, int scaled );
int sv_get_number_of_patterns( int slot );
int sv_find_pattern( int slot, const char* name );
int sv_get_pattern_x( int slot, int pat_num );
int sv_get_pattern_y( int slot, int pat_num );
int sv_get_pattern_tracks( int slot, int pat_num );
int sv_get_pattern_lines( int slot, int pat_num );
const char* sv_get_pattern_name( int slot, int pat_num );
sunvox_note* sv_get_pattern_data( int slot, int pat_num );
int sv_pattern_mute( int slot, int pat_num, int mute );
uint32_t sv_get_ticks( void );
uint32_t sv_get_ticks_per_second( void );
const char* sv_get_log( int size );
]])

local function loadSunvox(path)
	local osString = ls.getOS()
	local arch = assert(path[ffi.arch], "Architecture " .. ffi.arch .. " not supported or not found")
	local isAndroid = osString == 'Android'
	local lib
	if isAndroid then
		lib = assert(arch['Android'], ffi.os .. " not supported or not found")
	else
		lib = assert(arch[ffi.os], ffi.os .. " not supported or not found")
	end
	
	print(isAndroid)
	print(lib)
	
	local filename = love.path.leaf(lib)

	if not love.filesystem.getInfo(filename) then
		local libfile = assert(love.filesystem.read(lib))
		assert(love.filesystem.write(filename, libfile))
	end

	return ffi.load(love.filesystem.getSaveDirectory() .. '/' .. filename)
end

local sv
local C = ffi.C
local MAX_SLOTS = 4

local InitFlags = {
	NO_DEBUG_OUTPUT     = C.SV_INIT_FLAG_NO_DEBUG_OUTPUT,
	USER_AUDIO_CALLBACK = C.SV_INIT_FLAG_USER_AUDIO_CALLBACK,
	OFFLINE             = C.SV_INIT_FLAG_OFFLINE,
	AUDIO_INT16         = C.SV_INIT_FLAG_AUDIO_INT16,
	AUDIO_FLOAT32       = C.SV_INIT_FLAG_AUDIO_FLOAT32,
	ONE_THREAD          = C.SV_INIT_FLAG_ONE_THREAD,
}

local Moonvox = { _slots = setmetatable({}, { __mode = 'v' }) }
local Player = {}

function Moonvox.init(path, freq, channels, config, ...)
	if sv then return end

	sv = loadSunvox(path)
	freq = freq or 44100
	channels = channels or 2

	local flags = 0
	for i = 1, select('#', ...) do
		local f = (select(i, ...))
		if not InitFlags[f] then
			error("Invalid init flag: " .. f)
		end

		flags = flags + InitFlags[f]
	end

	return sv.sv_init(config, freq, channels, flags)
end

local function collectSlot(handle)
	sv.sv_close_slot(handle[0])
end

function Moonvox.open_slot(slot)
	if type(slot) ~= 'number' or math.floor(slot) ~= slot or slot < 0 or slot >= MAX_SLOTS then
		return nil, "Invalid slot " .. slot
	end

	if Moonvox._slots[slot] then
		return nil, "Slot " .. slot .. " already open"
	end

	if sv.sv_open_slot(slot) ~= 0 then
		return nil, "Could not open slot"
	end

	local handle = ffi.gc(ffi.new('int[1]', slot), collectSlot)
	Moonvox._slots[slot] = handle

	return handle
end

function Moonvox.close_slot(handle)
	local slot = handle[0]
	if not Moonvox._slots[slot] then
		return false, "Slot " .. slot .. " not open"
	end

	ffi.gc(Moonvox._slots[slot], nil)
	sv.sv_close_slot(slot)
	Moonvox._slots[slot] = nil
	return true
end

function Moonvox.play(handle)
	return sv.sv_play(handle[0]) == 0
end

function Moonvox.play_from_beginning(handle)
	return sv.sv_play_from_beginning(handle[0]) == 0
end

function Moonvox.stop(handle)
	return sv.sv_stop(handle[0]) == 0
end

function Moonvox.deinit()
	for _, v in pairs(Moonvox._slots) do
		Moonvox.close_slot(v)
	end
	return sv.sv_deinit() == 0
end

function Moonvox.set_autostop(handle, autostop)
	return sv.sv_set_autostop(handle[0], autostop and 1 or 0) == 0
end

function Moonvox.end_of_song(handle)
	return sv.sv_end_of_song(handle[0]) ~= 0
end

function Moonvox.volume(handle, volume)
	return sv.sv_volume(handle[0], math.max(0, math.min(256, volume))) == 0
end

function Moonvox.load_from_memory(handle, data, size)
	return sv.sv_load_from_memory(handle[0], data, size) == 0
end

function Moonvox.get_free_slot()
	for i = 0, MAX_SLOTS - 1 do
		if not Moonvox._slots[i] then
			return i
		end
	end
end

local function getSongData(source)
	if type(source) == 'string' then
		if #source > 8 and source:sub(1, 8) == 'SVOX\x00\x00\x00\x00' then
			return source
		else
			local d, err = love.filesystem.read(source)
			if d then return d end
			return nil, err
		end
	elseif type(source) == 'userdata' and source.getString then
		return source:getString()
	end
end

function Moonvox.newPlayer(file)
	local slot = Moonvox.get_free_slot()
	if not slot then
		return nil, "Out of SunVox slots"
	end

	local data = getSongData(file)
	if not data then
		return nil, "Invalid song source"
	end

	local handle, err = Moonvox.open_slot(slot)
	if not handle then return nil, err end

	if not Moonvox.load_from_memory(handle, ffi.cast('void*', data), #data) then
		Moonvox.close_slot(handle)
		return nil, "Could not load SunVox song"
	end

	return setmetatable({
		_handle = handle
	}, Player)
end

-----------------------------------------------------------------------------

Player.__index = Player

function Player:play(fromBeginning)
	local play = fromBeginning and Moonvox.play_from_beginning or Moonvox.play
	return play(self._handle)
end

function Player:stop()
	return Moonvox.stop(self._handle)
end

function Player:release()
	Moonvox.close_slot(self._handle)
	self._handle = nil
end

function Player:setAutostop(autostop)
	return Moonvox.set_autostop(self._handle, autostop)
end

function Player:setVolume(volume)
	return Moonvox.volume(self._handle, math.max(0, math.min(256, volume * 256)))
end

function Player:hasEnded()
	return Moonvox.end_of_song(self._handle)
end

-----------------------------------------------------------------------------

return Moonvox
