local mv = require('moonvox')

mv.init() -- required at startup!

local player = assert(mv.newPlayer('test.sunvox'))
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
