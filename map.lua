overworld_levels = {	{x = -1, y = -1, func = function () end, name = 'Overworld', persist = true},
						{x = 41, y = 15, func = function (dir) map_hakurei_shrine(dir) end, name = 'Hakurei Shrine', persist = true},
						{x = 17, y = 13, func = function (dir) map_kirisame_house(dir) end, name = 'Marisa Kirisame\'s house', persist = true},
						{x = 24, y = 16, func = function (dir) map_margatroid_house(dir) end, name = 'Alice Margatroid\'s house', persist = true},
						{x = 39, y = 13, func = function (dir) map_easy_cave(dir) end, name = 'Easy Dungeon', persist = true, mon_gen = 1},
						{x = 22, y = 20, func = function (dir) map_human_village(dir) end, name = 'Human Village', persist = false},
						{x = 43, y = 15, func = function (dir) map_easy_cavern(dir) end, name = 'Easy Cavern', persist = true, mon_gen = 1},
					}

function next_level(dir)

	if level_connection[dir] then
		save_map_check()
		save_player()
		level_connection[dir](dir)
		map_back_canvas_draw()
		player_fov()
	end

end

function map_overworld(dir)

	local prev_level = level.name 
	level = {name = 'Overworld', depth = 1}
	level_connection = {up = nil, down = nil}

	if not load_map() then	
		local chunk = love.filesystem.load('map/overworld.lua')
		chunk()	
	end
	
	if prev_level == 'Hakurei Shrine' then
		map_new_place_player(41, 15)
	elseif prev_level == 'Marisa Kirisame\'s house' then
		map_new_place_player(17, 13)
	elseif prev_level == 'Alice Margatroid\'s house' then
		map_new_place_player(24, 16)
	elseif prev_level == 'Easy Dungeon' then
		map_new_place_player(39, 13)
	elseif prev_level == 'Human Village' then
		map_new_place_player(22, 20)
	else
		map_new_place_player(23, 23)
	end
		
end

function map_human_village(dir)

	local chunk = love.filesystem.load('map/human_village.lua')
	chunk()
	level = {name = 'Human Village', depth = 1}
	level_connection = {up = function () map_overworld() end, down = nil}
	map_new_place_player(20, 30)

end

function map_hakurei_shrine(dir)

	local chunk = love.filesystem.load('map/hakurei_shrine.lua')
	chunk()
	level = {name = 'Hakurei Shrine', depth = 1}
	level_connection = {up = function () map_overworld() end, down = nil}
	map_new_place_player(24, 30)
	
end

function map_kirisame_house(dir)

	local chunk = love.filesystem.load('map/kirisame_house.lua')
	chunk()
	level = {name = 'Marisa Kirisame\'s house', depth = 1}
	level_connection = {up = function () map_overworld() end, down = nil}
	map_new_place_player(32, 31)
	
end

function map_margatroid_house(dir)

	local chunk = love.filesystem.load('map/margatroid_house.lua')
	chunk()
	level = {name = 'Alice Margatroid\'s house', depth = 1}
	level_connection = {up = function () map_overworld() end, down = nil}
	map_new_place_player(22, 31)
	
end

function map_easy_cavern(dir)

	--- another stupid and non abstract moving method
	if level.name ~= 'Easy Cavern' then
		level = {name = 'Easy Cavern', depth = 1}
		dir = 'down'
		level_connection = {up = function () map_overworld() end, down = function () map_easy_cavern('down') end}
	elseif level.name == 'Easy Cavern' then
			if dir == 'down' then 
			level.depth = level.depth + 1
			level_connection = {up = function () map_easy_cavern('up') end, down = function () map_easy_cavern('down') end}
		elseif dir == 'up' then 
			level.depth = level.depth - 1	
			if level.depth == 1 then
				level_connection = {up = function () map_overworld() end, down = function () map_easy_cavern('down') end}
			else
				level_connection = {up = function () map_easy_cavern('up') end, down = function () map_easy_cavern('down') end}
			end
		end
	end
	
	--- map not found, create one instead
	if not load_map() then
		
		if level.depth > 0 then
			stairs = map_gen_cave(map_width, map_height)
			if dir == 'down' then
				map_new_place_player(stairs.up.x, stairs.up.y)
			elseif dir == 'up' then
				map_new_place_player(stairs.down.x, stairs.down.y)
			end
			
			--- now add in monsters and items to the map
			monster_maker(math.random(7, 9))
			item_maker(math.random(4, 7))
			
		--- back on the overworld
		elseif level.depth < 1 then
			map_overworld(dir)
		end
		
	--- loaded previous cave map, set player at map entrance now
	else
		place_player_on_stairs(dir)
	end

end

function map_easy_cave(dir)

	--- moving up and down through the cave.  I need to abstract and simplify this later for other levels
	if level.name ~= 'Easy Dungeon' then
		level = {name = 'Easy Dungeon', depth = 1}	
		dir = 'down'
		level_connection = {up = function () map_overworld() end, down = function () map_easy_cave('down') end}
	elseif level.name == 'Easy Dungeon' then
		if dir == 'down' then 
			level.depth = level.depth + 1
			level_connection = {up = function () map_easy_cave('up') end, down = function () map_easy_cave('down') end}
		elseif dir == 'up' then 
			level.depth = level.depth - 1	
			if level.depth == 1 then
				level_connection = {up = function () map_overworld() end, down = function () map_easy_cave('down') end}
			else
				level_connection = {up = function () map_easy_cave('up') end, down = function () map_easy_cave('down') end}
			end
		end
	end
	
	--- map wasnt found, create one instead
	if not load_map() then	
	
		--- still in the caves
		if level.depth > 0 then
		
			stairs = map_gen_rogue(map_width, map_height)	
			if dir == 'down' then
				map_new_place_player(stairs.up.x, stairs.up.y)
			elseif dir == 'up' then
				map_new_place_player(stairs.down.x, stairs.down.y)
			end
			
			--- now add in monsters and items to the map
			monster_maker(math.random(7, 9))
			item_maker(math.random(4, 7))
		
		--- back on the overworld
		elseif level.depth < 1 then
			map_overworld(dir)
		end
	
	--- loaded previous cave map, set player at map entrance now
	else
		place_player_on_stairs(dir)
	end
	
	--- if last cave level then place a magic mirror
	if level.depth == 5 then
		local placed = false
		repeat
		
			local x = math.random(1, map_width)
			local y = math.random(1, map_height)
			print(x, y)
			if not map[x][y]:get_block_move() then
				map[x][y]:set_items({Item:new(game_items[7])})
				placed = true
			end
		
		until placed
	end
	
end

function place_player_on_stairs(dir)

	for x = 1, 46 do
		for y = 1, 33 do
			if map[x][y]:get_char() == '>' and dir == 'up' then
				map_new_place_player(x, y)
				break
			elseif map[x][y]:get_char() == '<' and dir == 'down' then
				map_new_place_player(x, y)
				break
			end
		end
	end

end

function save_map_check()

	for i = 1, # overworld_levels do
		if overworld_levels[i].name == level.name and overworld_levels[i].persist then
			save_map()
		end
	end
	
end

function map_set_all_seen()

	for x = 1, map_width do
		for y = 1, map_height do
			map[x][y]:set_unlit()
			map[x][y]:set_seen()		
		end
	end

end

function map_gen_cave(width, height)

	--- clear the map
	for x = 1, width do
		for y = 1, height do
			map[x][y] = Tile:new({name = 'Wall', x = x, y = y})
		end
	end
	
	--- DLA cave generator
	map[math.floor(width/2)][math.floor(height/2)] = Tile:new({name = 'Floor', x = math.floor(width/2), y = math.floor(height/2)})
	local tiles_placed = 0
	repeat
	
		local placed = false
		local x = math.random(1, width)
		local y = math.random(1, height)
		repeat
		
			local dx = math.random(-1, 1)
			local dy = math.random(-1, 1)
			
			x = x + dx
			y = y + dy
			
			if x < 1 then x = 1 end
			if x > width then x = width end
			if y < 1 then y = 1 end
			if y > height then y = height end
			
			if not map[x][y]:get_block_move() then
				map[x-dx][y-dy] = Tile:new({name = 'Floor', x = x-dx, y = y-dy})
				placed = true
				tiles_placed = tiles_placed + 1
			end
		
		until placed
	
	until tiles_placed >= math.floor((width * height) * 0.75)
	
	--- surround map with walls
	for x = 1, width do
		map[x][1] = Tile:new({name = 'Wall', x = x, y = 1})
		map[x][height] = Tile:new({name = 'Wall', x = x, y = height})
	end
	for y = 1, height do
		map[1][y] = Tile:new({name = 'Wall', x = 1, y = y})
		map[width][y] = Tile:new({name = 'Wall', x = width, y = y})
	end
	
	--- place stairs
	local ustairs = false
	local dstairs = false
	local stairs = {}
	repeat
	
		local x1 = math.random(1, width)
		local y1 = math.random(1, height)
		local x2 = math.random(1, width)
		local y2 = math.random(1, height)
		
		if not map[x1][y1]:get_block_move() and not map[x2][y2]:get_block_move() then
			if x1 ~= x2 and y1 ~= y2 then
				map[x1][y1] = Tile:new({name = 'UStairs', x = x1, y = y1})
				map[x2][y2] = Tile:new({name = 'DStairs', x = x2, y = y2})
				ustairs = true
				dstairs = true
			end
		end
		
		stairs = {up = {x = x1, y = y1}, down = {x = x2, y = y2}}
	
	until ustairs and dstairs
	
	return stairs

end

function map_gen_rogue(width, height)
	
	local rooms = {}
	local rooms_placed = 0
	local UStairs = {}
	local DStairs = {}
	
	--- clear the map
	for x = 1, width do
		for y = 1, height do
			map[x][y] = Tile:new({name = 'Wall', x = x, y = y})
		end
	end
	
	--- place non overlapping rooms
	repeat
		
		local w = math.random(5, 12)
		local h = math.random(5, 12)
		local x = math.random(2, width - w - 1)
		local y = math.random(2, height - h - 1)
		
		local can_be_placed = true
		for i = 1, # rooms do
			if x <= rooms[i].x + rooms[i].w + 1 and x+w + 1 >= rooms[i].x
			and y <= rooms[i].y + rooms[i].h + 1 and y+h + 1 >= rooms[i].y then
				can_be_placed = false
			end
		end
		
		if can_be_placed then
		
			--- room floor
			for dx = x, x + w do
				for dy = y, y + h do
					map[dx][dy] = Tile:new({name = 'Floor', x = dx, y = dy})					
				end
			end
			--- room decorative walls
			for dx = x, x + w do
				map[dx][y] = Tile:new({name = 'Dwall', x = dx, y = y, char = '-', block_sight = true, block_move = true})
				map[dx][y+h] = Tile:new({name = 'Dwall', x = dx, y = y+h, char = '-', block_sight = true, block_move = true})
			end
			for dy = y, y + h do
				map[x][dy] = Tile:new({name = 'Dwall', x = x, y = dy, char = ' |', block_sight = true, block_move = true})
				map[x+w][dy] = Tile:new({name = 'Dwall', x = x+w, y = dy, char = ' |', block_sight = true, block_move = true})
			end
			map[x][y] = Tile:new({name = 'Dwall', x = x, y = y, char = '+', block_sight = true, block_move = true})
			map[x+w][y] = Tile:new({name = 'Dwall', x = x+w, y = y, char = '+', block_sight = true, block_move = true})
			map[x][y+h] = Tile:new({name = 'Dwall', x = x, y = y+h, char = '+', block_sight = true, block_move = true})
			map[x+w][y+h] = Tile:new({name = 'Dwall', x = x+w, y = y+h, char = '+', block_sight = true, block_move = true})
			
			table.insert(rooms, {x = x, y = y, w = w, h = h})
			rooms_placed = rooms_placed + 1
		end
	
	until rooms_placed > math.random(6, 8)

	--- place corridors between rooms, and add in stairs when appropriate
	for i = 1, # rooms - 1 do
		--- corridors
		local x1 = math.floor(rooms[i].x + rooms[i].w / 2)
		local y1 = math.floor(rooms[i].y + rooms[i].h / 2)
		local x2 = math.floor(rooms[i+1].x + rooms[i+1].w / 2)
		local y2 = math.floor(rooms[i+1].y + rooms[i+1].h / 2)
		for x = math.min(x1, x2), math.max(x1, x2) do
			if map[x][y1]:get_block_move() then map[x][y1] = Tile:new({name = "Floor", x = x, y = y1}) end
		end
		for y = math.min(y1, y2), math.max(y1, y2) do
			if map[x2][y]:get_block_move() then map[x2][y] = Tile:new({name = "Floor", x = x2, y = y}) end
		end
		
		--- stairs
		if i == 1 then
			map[x1][y1] = Tile:new({name = 'UStairs', x = x1, y = y1})
			UStairs = {x = x1, y = y1}
		elseif i == # rooms - 1 and level.depth < 5 then
			map[x1][y1] = Tile:new({name = 'DStairs', x = x1, y = y1})
			DStairs = {x = x1, y = y1}
		end
	end
	
	local stairs = {up = UStairs, down = DStairs}
	return stairs

end

function mon_gen_machine()

	for i = 1, # overworld_levels do
		if overworld_levels[i].name == level.name and overworld_levels[i].mon_gen then
			mon_gen(overworld_levels[i].mon_gen)
		end
	end

end

function mon_gen(level)

	if math.random(1000 - (level * 4)) <= level + player_level then
	
		local placed = false
		repeat
		
			local x = math.random(2, 45)
			local y = math.random(2, 32)
			
			if not map[x][y]:get_block_move() and not map[x][y]:get_lit() then
				local mon = map_random_monster()
				mon['x'] = x
				mon['y'] = y
				map[x][y]:set_holding(Creature:new(mon))
				placed = true
			end
		
		until placed 
	
	end

end

function monster_maker(num)

	--- Place monsters
	local placed = 0
	repeat
	
		local x = math.random(2, map_width-1)
		local y = math.random(2, map_height-1)
		
		if not map[x][y]:get_block_move() then
			local monster = map_random_monster()
			monster['x'] = x
			monster['y'] = y
			map[x][y]:set_holding(Creature:new(monster))
			placed = placed + 1
		end
	
	until placed == num

end

function item_maker(num)

	--- place items around the map
	local placed = 0
	repeat
	
		local x = math.random(1, map_width)
		local y = math.random(1, map_height)
		if not map[x][y]:get_block_move() then		
			local item = map_random_item()
			if item then 
				map[x][y]:set_items({Item:new(item)}) 	
				placed = placed + 1
			end
		end
	
	until placed > math.random(8, 10)

end

function map_random_monster()

	local chance = 0
	local dice_max = player_level + 1
	
	local dice = math.random(1, dice_max)
	for i = 1, # game_monsters do
		chance = chance + game_monsters[i].level
		if dice <= chance then
			return game_monsters[i]
		end
	end
	
	return game_monsters[1]
	
end

function map_random_item()
	
	local chance = 0
	local dice_max = 0 
	
	for i = 1, # game_items do
		chance = chance + game_items[i].prob
	end
	dice_max = chance
	chance = 0
	
	local dice = math.random(1, dice_max)
	for i = 1, # game_items do
		chance = chance + game_items[i].prob
		if dice <= chance then
			return game_items[i]
		end
	end

end

function map_new_place_player(x, y)

	player:set_x(x)
	player:set_y(y)
	map[x][y]:set_holding(player)

end

function map_get_surrounding_blocked(x, y)

	local surround = 0
	if map[x-1][y]:get_block_move() then surround = surround + 1 end
	if map[x+1][y]:get_block_move() then surround = surround + 1 end
	if map[x][y-1]:get_block_move() then surround = surround + 1 end
	if map[x][y+1]:get_block_move() then surround = surround + 1 end
	if map[x-1][y-1]:get_block_move() then surround = surround + 1 end
	if map[x-1][y+1]:get_block_move() then surround = surround + 1 end
	if map[x+1][y-1]:get_block_move() then surround = surround + 1 end
	if map[x+1][y+1]:get_block_move() then surround = surround + 1 end
	return surround
	
end

function map_use_tile()

	if map[player:get_x()][player:get_y()]:get_name() == 'Futon' then
		message_add("You lay down and rest on the futon...")
		message_add("... you wake up feeling much better.")
		player:heal(9999999)
		player:mheal(9999999)
		
	elseif map[player:get_x()][player:get_y()]:get_name() == 'Bed' then
		message_add("You lay down and rest on the bed...")
		message_add("... you wake up feeling much better.")
		player:heal(9999999)
		player:mheal(9999999)
		
	elseif map[player:get_x()][player:get_y()]:get_name() == 'Cooking Pot' then
		inventory_open = true
		inventory_action = 'cook'
		
	elseif map[player:get_x()][player:get_y()]:get_name() == 'Donation Box' then
		if player_gold >= 50 then
			message_add("You put some money into the donation box...")
			if math.random(1, 10) <= 8 then
				message_add("... Good luck!")
				add_modifier({name = 'Good Luck', speed = 2, armor = 2, turn = 1500})
			else
				message_add("... Bad luck!")
				add_modifier({name = 'Bad Luck', speed = -2, armor = -2, turn = 1500})
			end
			player_gold = player_gold - 50
		elseif player_gold < 50 then
			message_add("You don't have enough money to put in the donation box.")
		end
		
	end

end

function map_draw()

	love.graphics.setCanvas(map_canvas)
	love.graphics.setFont(game_font)
	map_canvas:clear()
	love.graphics.setBlendMode('alpha')
	
	for x = 1, map_width do
		for y = 1, map_height do
			
			love.graphics.setColor(0, 0, 0, 255)
			if not map[x][y]:get_seen() and not map[x][y]:get_lit() then
				love.graphics.rectangle('fill', ascii_draw_point(x), ascii_draw_point(y), char_width, char_width)
			end
			
			love.graphics.setColor(0, 0, 0, 210)
			if not map[x][y]:get_lit() and map[x][y]:get_seen() then
				love.graphics.rectangle('fill', ascii_draw_point(x), ascii_draw_point(y), char_width, char_width)
			end
			
			love.graphics.setColor(255, 255, 255, 255)			
			if map[x][y]:get_lit() then
				if map[x][y]:get_holding() then
					love.graphics.setColor(0, 0, 0, 255)
					love.graphics.rectangle('fill', ascii_draw_point(x), ascii_draw_point(y), char_width, char_width)
					love.graphics.setColor(255, 255, 255, 255)
					map[x][y]:draw_holding()
				elseif not map[x][y]:get_holding() and map[x][y]:get_items() then
					love.graphics.setColor(0, 0, 0, 255)
					love.graphics.rectangle('fill', ascii_draw_point(x), ascii_draw_point(y), char_width, char_width)
					love.graphics.setColor(255, 255, 255, 255)
					map[x][y]:get_items()[1]:draw(x, y)
				end
			end
		
		end
	end
	
	love.graphics.setCanvas()
	love.graphics.draw(map_back_canvas)
	love.graphics.draw(map_canvas)
	
end

function map_back_canvas_draw()

	love.graphics.setCanvas(map_back_canvas)
	love.graphics.setFont(game_font)
	map_back_canvas:clear()
	love.graphics.setBlendMode('alpha')
	love.graphics.setColor(255, 255, 255, 255)
	
	for x = 1, map_width do
		for y = 1, map_height do
			map[x][y]:draw_ascii()
		end
	end

	love.graphics.setCanvas()

end

function map_overworld_fov(x, y, range)

	for x = 1, map_width do
		for y = 1, map_height do
			if map[x][y] and map[x][y]:get_seen() then
				map[x][y]:set_lit()
			end
		end
	end
	
	for x = x - range, x + range do
		for y = y - range, y + range do
			if map[x][y] then
				map[x][y]:set_seen()
				map[x][y]:set_lit()
			end
		end
	end

end

function cast_light(cx, cy, row, light_start, light_end, radius, xx, xy, yx, yy, id)

	if light_start < light_end then return end
	local radius_sq = radius * radius
	for j = row, radius do
		local dx = -1 * j - 1
		local dy = -1 * j
		local blocked = false
		while dx <= 0 do
			dx = dx + 1
			local mx = cx + dx * xx + dy * xy
			local my = cy + dx * yx + dy * yy
			local l_slope = (dx-0.5)/(dy+0.5)
			local r_slope = (dx+0.5)/(dy-0.5)
			if light_start < r_slope then
				--- the ruby version this is translated from
				--- had a next here, so yeah...
				local foo = false
			elseif light_end > l_slope then
				break
			else
				if (dx*dx + dy*dy) < radius_sq then map[mx][my]:set_lit() end
				if blocked then
					if map[mx][my]:get_block_sight() then
						new_start = r_slope
						--- another next...
					else
						blocked = false
						light_start = new_start
					end
				else
					if map[mx][my]:get_block_sight() and j < radius then
						blocked = true
						cast_light(cx, cy, j+1, light_start, l_slope, radius, xx, xy, yx, yy, id+1)
						new_start = r_slope
					end
				end
			end
		end
		if blocked then break end
	end

end

function map_calc_fov(x, y, range)
	
	local start_x = x - range - 1
	local start_y = y - range - 1
	local end_x = x + range + 1
	local end_y = y + range + 1
	
	if start_x < 1 then start_x = 1 end
	if start_y < 1 then start_y = 1 end
	if end_x > map_width then end_x = map_width end
	if end_y > map_height then end_y = map_height end

	for x = start_x, end_x do
		for y = start_y, end_y do
			if map[x][y] and map[x][y]:get_lit() then
				map[x][y]:set_unlit()
				map[x][y]:set_seen()
			end
		end
	end
	
	start_x = x
	start_y = y
	
	local mult = {	{1, 0, 0, -1, -1, 0, 0, 1},
					{0, 1, -1, 0, 0, -1, 1, 0},
					{0, 1, 1, 0, 0, -1, -1, 0},
					{1, 0, 0, 1, -1, 0, 0, -1},
					}
					
	map[x][y]:set_lit()
	for i = 1, 8 do
		cast_light(start_x, start_y, 1, 1.0, 0.0, range, mult[1][i], mult[2][i], mult[3][i], mult[4][i], 0)
	end
	
end