local state = 'enter'
local option = 1
local feats_chosen = 0
local main_options = {	'New Game',
						'Load Game',
						'Quit Game',
						}
local char_options = {	'Reimu Hakurei A',
						'Reimu Hakurei B',
						'Reimu Hakurei C',
						'Reimu Hakurei D',
						}
						
local title = love.graphics.newImage("media/title.png")
local bg = love.graphics.newImage("media/bg.png")

local reimu_a = love.graphics.newImage("media/reimua.png")
local reimu_b = love.graphics.newImage("media/reimub.png")
local reimu_c = love.graphics.newImage("media/reimuc.png")
local reimu_d = love.graphics.newImage("media/reimud.png")

love.graphics.setFont(love.graphics.newFont())
local font = love.graphics.getFont()
						
choice = ''

function menu:enter()
	state = 'enter'
	choice = ''
	feats_chosen = 0
	
	if love.filesystem.exists("player.lua") then
		option = 2
	end
	
end

function menu:draw()
	if state == 'main' then main_draw() 
	elseif state == 'char' then char_draw() 
	elseif state == 'enter' then enter_draw() 
	elseif state == 'feat' then feat_draw() end
	love.window.setTitle("TouhouLike V:0.0.13")
	love.graphics.print("TouhouLike V:0.0.13 by Jesse MacKellar", 2, 751)
end

function menu:keypressed(key)
	if state == 'main' then main_key(key)
	elseif state == 'char' then char_key(key)
	elseif state == 'enter' then enter_key(key)
	elseif state == 'feat' then feat_key(key) end
end

function feat_draw()

	love.graphics.draw(bg, 0, 0)
	
	local start_x = 100
	local start_y = 150
	local height = 30
	local width = 600
	local message = ""
	
	for i = 1, # player_feats do
		height = height + 30
	end
	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x, start_y - 10, width, height + 20)
	love.graphics.setColor(255, 255, 255, 255)
	
	love.graphics.print("Choose your feats.  " .. 2 - feats_chosen .. " choices remaining.  Press ENTER to continue.", start_x + 20, start_y)
	for i = 1, # player_feats do
		message = ""
		if player_feats[i].have then
			message = message .. "[" .. alphabet[i] .. "]: "
			message = message .. player_feats[i].name
		else
			message = message .. alphabet[i] .. ": " .. player_feats[i].name
		end
		love.graphics.print(message, start_x + 10, start_y + (i * 30))
		love.graphics.print(player_feats[i].desc, start_x + 20, start_y + (i * 30) + 15)
	end
	
end

function feat_key(key)
	
	for i = 1, # player_feats do
		if key == alphabet[i] then
			if not player_feats[i].have then 
				if feats_chosen < 2 then
					player_feats[i].have = true
					feats_chosen = feats_chosen + 1
				end
			else
				player_feats[i].have = false
				feats_chosen = feats_chosen - 1
			end
		end
	end
	
	if key == 'return' or key == 'kpenter' then
		Gamestate.switch(game)
	end

end

function enter_draw()
	love.graphics.draw(bg, 0, 0)
	
	local text = 'Press any key to continue'	
	local width = font:getWidth(text)
	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', 512 - width/2 - 10, 0, width + 20, 18)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(text, 512 - width/2, 2)
	
end

function enter_key(key)
	if key then state = 'main' end
end

function char_draw()

	--- menu art
	love.graphics.draw(bg, 0, 0)
	--love.graphics.draw(title, 344, 10)

	--- options
	local start_x = 98
	local start_y = 200

	--- character descriptions
	if option == 1 then
		love.graphics.draw(reimu_a, start_x + 150, start_y + 5)
	elseif option == 2 then
		love.graphics.draw(reimu_b, start_x + 150, start_y + 5)
	elseif option == 3 then
		love.graphics.draw(reimu_c, start_x + 150, start_y + 5)
	elseif option == 4 then
		love.graphics.draw(reimu_d, start_x + 150, start_y + 5)
	end
	
	--- options
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x - 10, start_y + 15 - 10, 127, 65)
	love.graphics.setColor(255, 255, 255, 255)
	
	for i = 1, # char_options do
		if option == i then
			--- character names
			local width = font:getWidth(char_options[i])
			love.graphics.rectangle('fill', start_x - 2, start_y + (15 * i), width + 4, 12)
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.print(char_options[i], start_x, start_y + (15 * i))
			love.graphics.setColor(255, 255, 255, 255)
		else
			love.graphics.print(char_options[i], start_x, start_y + (15 * i))
		end
	end		

end

function char_key(key)

	if key == 'kp2' or key == 'down' then
		option = option + 1 
	end
	if key == 'kp8' or key == 'up' then
		option = option - 1
	end
	
	if option < 1 then option = 1 end
	if option > # char_options then option = # char_options end
	
	if key == 'return' or key == 'kpenter' then		
		local files = love.filesystem.getDirectoryItems("")
		for k, file in ipairs(files) do	
			love.filesystem.remove(file)
		end
		choice = char_options[option]
		state = 'feat'
	end
	
end

function main_draw()

	--- menu art
	love.graphics.draw(bg, 0, 0)
	--love.graphics.draw(title, 344, 10)

	--- options
	local start_x = 98
	local start_y = 200
	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x - 10, start_y + 15 - 10, 90, 65)
	love.graphics.setColor(255, 255, 255, 255)
	
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
			if main_options[i] == 'Load Game' and not love.filesystem.exists("player.lua") then
				love.graphics.setColor(100, 100, 100, 255)
			end
			love.graphics.print(main_options[i], start_x, start_y + (15 * i))
			love.graphics.setColor(255, 255, 255, 255)
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
	
	if option == 2 and not love.filesystem.exists("player.lua") then
		if key == 'kp2' or key == 'down' then
			option = 3
		end
		if key == 'kp8' or key == 'up' then
			option = 1
		end
	end
	
	if option < 1 then option = 1 end
	if option > # main_options then option = # main_options end
	
	if key == 'return' or key == 'kpenter' then
		choice = main_options[option]
		
		if choice == 'New Game' then 
			state = 'char' 
		elseif choice == 'Load Game' and love.filesystem.exists("player.lua") then
			load_player()
			choice = player_name
			Gamestate.switch(game)
		elseif choice == 'Quit Game' then
			love.event.push('quit')
		end
		
	end

end