local mv = require('moonvox')

local SUNVOX_PATH = {
	x86 = {
		Linux =   'sunvox_lib/linux/lib_x86/sunvox.so',
		Windows = 'sunvox_lib/windows/lib_x86/sunvox.dll',
	},
	x64 = {
		Linux    = 'sunvox_lib/linux/lib_x86_64/sunvox.so',
		Windows  = 'sunvox_lib/windows/lib_x86_64/sunvox.dll',
		OSX      = 'sunvox_lib/macos/lib_x86_64/sunvox.dylib',
	},
	-- TODO: add other architectures
}

mv.init(SUNVOX_PATH) -- required at startup!

local player = assert(mv.newPlayer('sunvox_lib/resources/test.sunvox'))
player:setAutostop(true) -- songs play in loop by default
player:play()

function love.keypressed(key)
	if key == 'space' then
		if player:hasEnded() then
			player:play(true)
		else
			player:stop()
		end
	elseif key == 'escape' then
		love.event.quit()
	end
end

function love.draw()
	if not player then return end
	if not player:hasEnded() then
		love.graphics.print("Song is playing")
	else
		love.graphics.print("Song has ended")
	end
end

function love.quit()
	mv.deinit() -- required!
end
