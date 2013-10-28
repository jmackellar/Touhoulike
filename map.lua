function map_test(width, height)

	--- Testing maps created in the map editor
	local chunk = love.filesystem.load('map/test.lua')
	chunk()
	map_new_place_player(3, 3)
	
end

function map_gen_forest_2(width, height)
	--- using DLA
	map_setup(width, height)
	for x = 1, width do
		for y = 1, height do
			map[x][y] = Tile:new({name = 'Tree', x = x, y = y})
		end
	end
	
	--- initial floor seed
	map[math.floor(width/2)][math.floor(height/2)] = Tile:new({name = 'Floor', x = math.floor(width/2), y = math.floor(height/2)})
	map[math.floor(width/2)-1][math.floor(height/2)] = Tile:new({name = 'Floor', x = math.floor(width/2)-1, y = math.floor(height/2)})
	map[math.floor(width/2)+1][math.floor(height/2)] = Tile:new({name = 'Floor', x = math.floor(width/2)+1, y = math.floor(height/2)})
	map[math.floor(width/2)][math.floor(height/2)-1] = Tile:new({name = 'Floor', x = math.floor(width/2), y = math.floor(height/2)-1})
	map[math.floor(width/2)][math.floor(height/2)+1] = Tile:new({name = 'Floor', x = math.floor(width/2), y = math.floor(height/2)+1})
	
	local placed = 0
	local continue = false
	
	--- placing the rest of the floor, brownian noise shit
	repeat
	
		local x = math.random(3, width-3)
		local y = math.random(3, height-3)
		continue = false
		tile_placed = false
		
		if not map[x][y]:get_block_move() then continue = true end
		
		if not continue then
			continue = false
			tile_placed = false
			
			repeat
					
				dx = math.random(-1, 1)
				dy = math.random(-1, 1)
				if not map[x+dx][y+dy]:get_block_move() then 
					map[x][y] = Tile:new({name = 'Floor', x = x, y = y})
					map[x-1][y] = Tile:new({name = 'Floor', x = x-1, y = y})
					map[x+1][y] = Tile:new({name = 'Floor', x = x+1, y = y})
					map[x][y-1] = Tile:new({name = 'Floor', x = x, y = y-1})
					map[x][y+1] = Tile:new({name = 'Floor', x = x, y = y+1})
					tile_placed = true
					placed = placed + 2
				else
					x = x + dx
					y = y + dy
					if x < 3 then x = 3 end
					if x > width-3 then x = width-3 end
					if y < 3 then y = 3 end
					if y > height-3 then y = height-3 end
				end
			
			until tile_placed
		end
	
	until placed >= math.floor((width * height) * .20)
	
	--- place a circular lake
	if math.random(1, 100) <= 45 then
		local x = math.random(8, width-8)
		local y = math.random(8, height-8)
		local radius = math.random(4, 7)
		
		for i = 1, radius do
			local err = 1 - i
			local err_y = 1
			local err_x = -2 * i
			local dx = i
			local dy = 0
			
			map[x][y + i] = Tile:new({name = 'Water', x = x, y = y + i})
			map[x][y - i] = Tile:new({name = 'Water', x = x, y = y - i})
			map[x + i][y] = Tile:new({name = 'Water', x = x + i, y = y})
			map[x - i][y] = Tile:new({name = 'Water', x = x - i, y = y})
			
			while dy < dx do
			
				if err > 0 then
					dx = dx - 1
					err_x = err_x + 2
					err = err + err_x
				end
				
				dy = dy + 1
				err_y = err_y + 2
				err = err + err_y
				map[x + dx][y + dy] = Tile:new({name = 'Water', x = x + dx, y = y + dy})
				map[x - dx][y + dy] = Tile:new({name = 'Water', x = x - dx, y = y + dy})
				map[x + dx][y - dy] = Tile:new({name = 'Water', x = x + dx, y = y - dy})
				map[x - dx][y - dy] = Tile:new({name = 'Water', x = x - dx, y = y - dy})
				map[x + dy][y + dx] = Tile:new({name = 'Water', x = x + dy, y = y + dx})
				map[x - dy][y + dx] = Tile:new({name = 'Water', x = x - dy, y = y + dx})
				map[x + dy][y - dx] = Tile:new({name = 'Water', x = x + dy, y = y - dx})
				map[x - dy][y - dx] = Tile:new({name = 'Water', x = x - dy, y = y - dx})
			
			end
		end
	end
	
	--- Place monsters
	local placed = 0
	repeat
	
		local x = math.random(2, width-1)
		local y = math.random(2, height-1)
		
		if not map[x][y]:get_block_move() then
			local monster = map_random_monster()
			monster['x'] = x
			monster['y'] = y
			map[x][y]:set_holding(Creature:new(monster))
			placed = placed + 1
		end
	
	until placed == math.random(8, 11)
	
	--- Place downstairs
	local placed = false
	repeat
	
		local x = math.random(1, width)
		local y = math.random(1, height)
		if not map[x][y]:get_block_move() then
			map[x][y] = Tile:new({name = 'DStairs', x = x, y = y})
			placed = true
		end
			
	until placed
	
	--- Place upstairs and/or player
	local placed = false
	repeat
	
		local x = math.random(1, width)
		local y = math.random(1, height)
		if not map[x][y]:get_block_move() and map[x][y]:get_name() ~= 'DStairs' then			
			if level.depth > 1 then
				map[x][y] = Tile:new({name = 'UStairs', x = x, y = y})
			end
			map_new_place_player(x, y)
			placed = true
		end
			
	until placed
	
	--- place items around the map
	local placed = 0
	repeat
	
		local x = math.random(1, width)
		local y = math.random(1, height)
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

function map_draw()

	love.graphics.setCanvas(map_canvas)
	map_canvas:clear()
	love.graphics.setBlendMode('alpha')
	for x = 1, map_width do
		for y = 1, map_height do
			if (not map[x][y]:get_holding() and not map[x][y]:get_items()) or not map[x][y]:get_lit() then 
				map[x][y]:draw_ascii()
			elseif map[x][y]:get_holding() and map[x][y]:get_lit() then
				map[x][y]:get_holding():draw_ascii(x, y) 
			elseif map[x][y]:get_items() and map[x][y]:get_lit() then
				map[x][y]:get_items()[1]:draw(x, y)
			end
		end
	end
	love.graphics.setCanvas()
	love.graphics.draw(map_canvas)
	
end

function map_calc_fov(x, y, range)
	
	local start_x = x - range - 5
	local start_y = y - range - 5
	local end_x = x + range + 5
	local end_y = y + range + 5
	
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
	
	-- Set the player's square to visible, because the following routine doesn't
	map[player:get_x()][player:get_y()]:set_lit()
	
	for angle = 1, 360, 0.18 do
		local dist = 0
		local x = start_x + 0.5
		local y = start_y + 0.5
		local xmove = math.cos(angle)
		local ymove = math.sin(angle)
		
		if x < 1 or x > map_width+1 then break end
		if y < 1 or y > map_height+1 then break end
		
		local quit = false
		repeat
			x = x + xmove
			y = y + ymove
			dist = dist + 1
			if dist > range then quit = true end
			if x > map_width+1 then quit = true end
			if y > map_height+1 then quit = true end
			if x < 1 then quit = true end
			if y < 1 then quit = true end
			
			if quit then break end
			
			if map[math.floor(x)][math.floor(y)] then map[math.floor(x)][math.floor(y)]:set_lit() end
			if map[math.floor(x)][math.floor(y)] then if map[math.floor(x)][math.floor(y)]:get_block_sight() then quit = true end end
		until quit
	end
	
end