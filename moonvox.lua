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

--[[
SunVox Library (modular synthesizer)
Copyright (c) 2008 - 2019, Alexander Zolotov <nightradio@gmail.com>, WarmPlace.ru
--]]

local ffi = require('ffi')

local MAX_SLOTS = 4

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
    uint8_t	note;           /* NN: 0 - nothing; 1..127 - note num; 128 - note off; 129, 130... - see NOTECMD_xxx defines */
    uint8_t	vel;            /* VV: Velocity 1..129; 0 - default */
    uint16_t	module;         /* MM: 0 - nothing; 1..65535 - module number + 1 */
    uint16_t	ctl;            /* 0xCCEE: CC: 1..127 - controller number + 1; EE - effect */
    uint16_t	ctl_val;        /* 0xXXYY: value of controller or effect */
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

/*
   Macros
*/
/*
#define SV_GET_MODULE_XY( in_xy, out_x, out_y ) out_x = in_xy & 0xFFFF; if( out_x & 0x8000 ) out_x -= 0x10000; out_y = ( in_xy >> 16 ) & 0xFFFF; if( out_y & 0x8000 ) out_y -= 0x10000;
#define SV_GET_MODULE_FINETUNE( in_finetune, out_finetune, out_relative_note ) out_finetune = in_finetune & 0xFFFF; if( out_finetune & 0x8000 ) out_finetune -= 0x10000; out_relative_note = ( in_finetune >> 16 ) & 0xFFFF; if( out_relative_note & 0x8000 ) out_relative_note -= 0x10000;
#define SV_PITCH_TO_FREQUENCY( in_pitch ) ( pow( 2, ( 30720.0F - (in_pitch) ) / 3072.0F ) * 16.3339 )
#define SV_FREQUENCY_TO_PITCH( in_freq ) ( 30720 - log2( (in_freq) / 16.3339 ) * 3072 )
*/

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
	local arch = assert(path[ffi.arch], "Architecture " .. ffi.arch .. " not supported")
	local lib = assert(arch[ffi.os], ffi.os .. " not supported")
	local filename = love.path.leaf(lib)

	if not love.filesystem.getInfo(filename) then
		local libfile = assert(love.filesystem.read(lib))
		assert(love.filesystem.write(filename, libfile))
	end

	return ffi.load(love.filesystem.getSaveDirectory() .. '/' .. filename)
end

local lib
local C = ffi.C

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
	if lib then return end

	lib = loadSunvox(path)
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

	return lib.sv_init(config, freq, channels, flags)
end

function Moonvox.open_slot(slot)
	if slot < 0 or slot >= MAX_SLOTS - 1 then
		return false, "Invalid slot " .. slot
	end

	if Moonvox._slots[slot] then
		return false, "Slot " .. slot .. " already open"
	end

	if lib.sv_open_slot(slot) ~= 0 then
		return false, "Could not open slot"
	end

	Moonvox._slots[slot] = ffi.gc(ffi.new('int[1]', slot), function()
		lib.sv_close_slot(slot)
	end)

	return true
end

function Moonvox.close_slot(slot)
	if not Moonvox._slots[slot] then
		return false, "Slot " .. slot .. " not open"
	end

	ffi.gc(Moonvox._slots[slot], nil)
	lib.sv_close_slot(slot)
	Moonvox._slots[slot] = nil
	return true
end

function Moonvox.play(slot, fromBeginning)
	local f = fromBeginning and lib.sv_play_from_beginning or lib.sv_play
	return f(slot) == 0
end

function Moonvox.stop(slot)
	return lib.sv_stop(slot) == 0
end

function Moonvox.deinit()
	for k, _ in pairs(Moonvox._slots) do
		Moonvox.close_slot(k)
	end
	return lib.sv_deinit()
end

function Moonvox.set_autostop(slot, autostop)
	return lib.sv_set_autostop(slot, autostop and 1 or 0) == 0
end

function Moonvox.end_of_song(slot)
	return lib.sv_end_of_song(slot) ~= 0
end

function Moonvox.volume(slot, volume)
	return lib.sv_volume(slot, math.max(0, math.min(256, volume))) == 0
end

function Moonvox.newPlayer(source)
	local data
	if type(source) == 'string' then
		if source:sub(1, 8) == 'SVOX\x00\x00\x00\x00' then
			data = source
		else
			local d, err = love.filesystem.read(source)
			if not d then return nil, err end
			data = d
		end
	elseif type(source) == 'userdata' and source.getString then
		data = source:getString()
	end

	local slot = -1
	for i = 0, MAX_SLOTS - 1 do
		if not Moonvox._slots[i] then
			slot = i
			break
		end
	end

	if slot == -1 then
		return nil, "Out of SunVox slots"
	end

	local ok, err = Moonvox.open_slot(slot)
	if not ok then return nil, err end

	if lib.sv_load_from_memory(slot, ffi.cast('void*', data), #data) ~= 0 then
		return nil, "Could not load SunVox song"
	end

	return Player.new(slot, Moonvox._slots[slot])
end

-----------------------------------------------------------------------------

Player.__index = Player

function Player.new(slot, handle)
	local self = setmetatable({
		_slot = slot,
		_handle = handle,
	}, Player)
	return self
end

function Player:play(fromBeginning)
	Moonvox.play(self._slot, fromBeginning)
end

function Player:stop()
	Moonvox.stop(self._slot)
end

function Player:release()
	Moonvox.close_slot(self._slot)
	self._handle, self._slot = nil
end

function Player:setAutostop(autostop)
	return Moonvox.set_autostop(self._slot, autostop)
end

function Player:setVolume(volume)
	return Moonvox.volume(self._slot, math.max(0, math.min(256, volume * 256)))
end

function Player:hasEnded()
	return Moonvox.end_of_song(self._slot)
end

-----------------------------------------------------------------------------

return Moonvox