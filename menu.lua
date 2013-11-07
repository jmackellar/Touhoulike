local state = 'main'
local option = 1
local main_options = {	'Reimu Hakurei A',
						'Reimu Hakurei B',
						}
						
choice = ''

function menu:enter()
	state = 'main'
end

function menu:draw()
	if state == 'main' then main_draw() end
end

function menu:keypressed(key)
	if state == 'main' then main_key(key) end
end

function main_draw()

	local start_x = 100
	local start_y = 75
	
	love.graphics.setFont(love.graphics.newFont())
	local font = love.graphics.getFont()
	for i = 1, # main_options do
		if option == i then
			local width = font:getWidth(main_options[i])
			love.graphics.rectangle('fill', start_x - 2, start_y + (15 * i), width + 4, 12)
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.print(main_options[i], start_x, start_y + (15 * i))
			love.graphics.setColor(255, 255, 255, 255)
		else
			love.graphics.print(main_options[i], start_x, start_y + (15 * i))
		end
	end		

end

function main_key(key)

	if key == 'kp2' or key == 'down' then
		option = option + 1 
	end
	if key == 'kp8' or key == 'up' then
		option = option - 1
	end
	
	if option < 1 then option = 1 end
	if option > # main_options then option = # main_options end
	
	if key == 'return' or key == 'kpenter' then
		choice = main_options[option]
		Gamestate.switch(game)
	end

end