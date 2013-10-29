function next_level(dir)

	if level_connection[dir] then
		level_connection[dir]()
		map_back_canvas_draw()
		player_fov()
	end

end

function map_overworld()

	local chunk = love.filesystem.load('map/overworld.lua')
	chunk()
	-- default player placing
	map_new_place_player(23, 23)
	
	if level.name == 'Hakurei Shrine' then
		map_new_place_player(41, 15)
	end
	
	level = {name = 'Overworld', depth = 1}
	level_connection = {up = nil, down = nil}
	map_set_all_seen()
	
end

function map_hakurei_shrine()

	local chunk = love.filesystem.load('map/hakurei_shrine.lua')
	chunk()
	level = {name = 'Hakurei Shrine', depth = 1}
	level_connection = {up = function () map_overworld() end, down = nil}
	map_new_place_player(24, 30)
	map_set_all_seen()
	
end

function map_set_all_seen()

	for x = 1, map_width do
		for y = 1, map_height do
			map[x][y]:set_unlit()
			map[x][y]:set_seen()		
		end
	end

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