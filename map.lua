overworld_levels = {	{x = -1, y = -1, func = function (dir) map_overworld(dir) end, name = 'Overworld', persist = true, dark = false},
						{x = -1, y = -1, func = function (dir) map_eientei(dir) end, name = 'Eientei', persist = true, dark = false},
						{x = -1, y = -1, func = function (dir) map_muenzuka(dir) end, name = 'Muenzuka', persist = true, dark = false},
						{x = -1, y = -1, func = function (dir) map_garden_of_the_sun(dir) end, name = 'Garden of the Sun', persist = true, dark = false},
						{x = -1, y = -1, func = function (dir) map_random_overworld_encounter('down') end, name = 'Wilderness', persist = true, dark = false,},
						{x = 41, y = 15, func = function (dir) map_hakurei_shrine('down') end, name = 'Hakurei Shrine', persist = true, dark = false,},
						{x = 17, y = 11, func = function (dir) map_kirisame_house(dir) end, name = 'Marisa Kirisame\'s house', persist = true, dark = false,},
						{x = 25, y = 15, func = function (dir) map_margatroid_house(dir) end, name = 'Alice Margatroid\'s house', persist = true, dark = false},
						{x = 39, y = 13, func = function (dir) map_easy_cave(dir) end, name = 'Easy Dungeon', persist = true, mon_gen = 1, dark = true},
						{x = 22, y = 20, func = function (dir) map_human_village(dir) end, name = 'Human Village', persist = false, dark = false},
						{x = 43, y = 15, func = function (dir) map_easy_cavern(dir) end, name = 'Easy Cavern', persist = true, mon_gen = 1, dark = true},
						{x = 21, y = 8, func = function (dir) map_sdm(dir) end, name = 'Scarlet Devil Mansion', persist = true, mon_gen = 3, dark = true},
						{x = 39, y = 24, func = function (dir) map_youkai_dungeon(dir) end, name = 'Youkai Forest', persist = true, mon_gen = 2, dark = false},
						{x = 21, y = 18, func = function (dir) map_kourindou(dir) end, name = 'Kourindou', persist = false, dark = false},
						{x = 24, y = 28, func = function (dir) map_eientei(dir) end, name = 'Bamboo Forest', persist = true, dark = false},	
						{x = 35, y = 9, func = function (dir) map_makai_entrance(dir) end, name = 'Eerie Cave', persist = true, dark = true},
						{x = 40, y = 27, func = function (dir) map_moriya_shrine(dir) end, name = 'Moriya Shrine', persist = false, dark = false},
						{x = 29, y = 3, func = function (dir) map_underground_ruins(dir) end, name = 'Underground Ruins', persist = true, mon_gen = 3, dark = true},
						{x = 38, y = 29, func = function (dir) map_youkai_mountain(dir) end, name = 'Youkai Mountain', persist = true, mon_gen = 3, dark = false},
						{x = 10, y = 22, func = function (dir) map_sanzu_river_east(dir) end, name = 'Sanzu River East', persist = false, dark = false},
						{x = 7, y = 22, func = function (dir) map_sanzu_river_west(dir) end, name = 'Sanzu River West', persist = false, dark = false},
						{x = 4, y = 18, func = function (dir) map_hakugyokurou(dir) end, name = 'Hakugyokurou', persist = true, dark = false},
					}
					
overworld_unlabelled_levels = {	{coords = {{x=9,y=13,d=1},{x=9,y=12,d=2},{x=8,y=13,d=3},{x=8,y=12,d=4},{x=7,y=12,d=5}}, func = function (dir) map_muenzuka(dir) end},
								{coords = {{x=17,y=22,d=1}}, func = function (dir) map_garden_of_the_sun(dir) end},
							}
					
overworld_coords = { x = 25, y = 25 }

function next_level(dir)

	if level_connection[dir] then	
		save_map_check()
		save_player()
		map_special_rooms = {}
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
		map_new_place_player(17, 11)
	elseif prev_level == 'Alice Margatroid\'s house' then
		map_new_place_player(25, 15)
	elseif prev_level == 'Easy Dungeon' then
		map_new_place_player(39, 13)
	elseif prev_level == 'Human Village' then
		map_new_place_player(22, 20)
	elseif prev_level == 'Easy Cavern' then
		map_new_place_player(43, 15)
	elseif prev_level == 'Scarlet Devil Mansion' then
		map_new_place_player(21, 8)
	elseif prev_level == 'Youkai Forest' then
		map_new_place_player(39, 24)
	elseif prev_level == 'Kourindou' then
		map_new_place_player(21, 18)
	elseif prev_level == 'Bamboo Forest' or prev_level == 'Eientei' then
		map_new_place_player(24, 28)
	elseif prev_level == 'Eerie Cave' then
		map_new_place_player(35, 9)
	elseif prev_level == 'Moriya Shrine' then
		map_new_place_player(40, 27)
	elseif prev_level == 'Underground Ruins' then
		map_new_place_player(29, 3)
	elseif prev_level == 'Youkai Mountain' then
		map_new_place_player(38, 29)
	elseif prev_level == 'Sanzu River East' then
		map_new_place_player(10, 22)
	elseif prev_level == 'Sanzu River West' then
		map_new_place_player(7, 22)
	elseif prev_level == 'Hakugyokurou' then
		map_new_place_player(4, 18)
	elseif prev_level == 'Muenzuka' then
		map_new_place_player(overworld_coords.x, overworld_coords.y)
	elseif prev_level == 'Garden of the Sun' then
		map_new_place_player(overworld_coords.x, overworld_coords.y)
	elseif prev_level == 'Wilderness' then
		map_new_place_player(overworld_coords.x, overworld_coords.y)
	else
		map_new_place_player(23, 23)
	end
		
end

function map_garden_of_the_sun(dir)

	level.depth = 1
	level.name = 'Garden of the Sun'
	level_connection = {up = function (dir) map_overworld(dir) end, down = function (dir) end}
	
	if not load_map() then
		map_gen_garden_of_the_sun(map_width, map_height, false, true)
	end
	
	place_player_on_stairs(dir)

end

function map_muenzuka(dir)

	level.depth = 1
	level.name = 'Muenzuka'
	level_connection = {up = function (dir) map_overworld(dir) end, down = function (dir) end}
	
	for i = 1, # overworld_unlabelled_levels do
		for k = 1, # overworld_unlabelled_levels[i].coords do
			if overworld_unlabelled_levels[i].coords[k].x == overworld_coords.x and overworld_unlabelled_levels[i].coords[k].y == overworld_coords.y then
				level.depth = overworld_unlabelled_levels[i].coords[k].d
				break
			end
		end
	end
	
	if not load_map() then
		map_gen_muenzuka(map_width, map_height, false, true)
	end
	
	place_player_on_stairs(dir)

end

function map_hakugyokurou(dir)

	if level.name == 'Overworld' then
		level.depth = 1 
	else
		if dir == 'down' then
			level.depth = level.depth + 1
		elseif dir == 'up' then
			level.depth = level.depth - 1
		end
	end
	
	level.name = 'Hakugyokurou'
	level_connection = {up = function (dir) map_overworld(dir) end, down = function (dir) map_hakugyokurou(dir) end}
	
	if not load_map() then
		local chunk = love.filesystem.load("map/hakugyokurou_entrance.lua")
		chunk()
	end
	
	place_player_on_stairs(dir)

end

function map_sanzu_river_east(dir)

	if level.name == 'Overworld' then
		level.depth = 1
	else
		if dir == 'down' then
			level.depth = level.depth + 1
		elseif dir == 'up' then
			level.depth = level.depth - 1
		end
	end
	
	level.name = 'Sanzu River East'
	level_connection = {up = function (dir) map_overworld(dir) end, down = function (dir) end}
	
	local chunk = love.filesystem.load("map/sanzu_river_east.lua")
	chunk()
	
	if dir == 'down' then
		place_player_on_stairs(dir)
	else
		map_new_place_player(18, 15)
	end

end

function map_sanzu_river_west(dir)

	if level.name == 'Overworld' then
		level.depth = 1
	else
		if dir == 'down' then
			level.depth = level.depth + 1
		elseif dir == 'up' then
			level.depth = level.depth - 1
		end
	end
	
	level.name = 'Sanzu River West'
	level_connection = {up = function (dir) map_overworld(dir) end, down = function (dir) end}
	
	local chunk = love.filesystem.load("map/sanzu_river_west.lua")
	chunk()
	
	if dir == 'down' then
		place_player_on_stairs(dir)
	else
		map_new_place_player(28, 16)
	end

end

function map_youkai_mountain(dir)

	if level.name == 'Overworld' then
		level.depth = 1
	else
		if dir == 'down' then
			level.depth = level.depth + 1
		elseif dir == 'up' then
			level.depth = level.depth - 1
		end
	end
	
	level.name = 'Youkai Mountain'
	level_connection = {up = function (dir) map_overworld(dir) end, down = function (dir) end}
	
	if not load_map() then
	
		local chunk = love.filesystem.load("map/youkai_mountain.lua")
		chunk()
	
	end
	
	place_player_on_stairs(dir)

end

function map_underground_ruins(dir)

	if level.name == 'Overworld' then
		level.depth = 1
	else
		if dir == 'down' then
			level.depth = level.depth + 1
		elseif dir == 'up' then
			level.depth = level.depth - 1
		end
	end
	
	level.name = 'Underground Ruins'
	
	if not load_map() then
		if level.depth > 1 and level.depth < 7 then			
			map_gen_variety(map_width, map_height, true, true)
		elseif level.depth == 1 then			
			map_gen_variety(map_width, map_height, true, true)
		elseif level.depth == 7 then			
			map_gen_variety(map_width, map_height, false, true)
		end
		monster_maker(math.random(10,15))
		item_maker(math.random(10,15))
	end
	
	if level.depth > 1 and level.depth < 7 then 
		level_connection = {up = function (dir) map_underground_ruins(dir) end, down = function (dir) map_underground_ruins(dir) end}
	elseif level.depth == 1 then
		level_connection = {up = function (dir) map_overworld(dir) end, down = function (dir) map_underground_ruins(dir) end}
	else
		level_connection = {up = function (dir) map_underground_ruins(dir) end, down = function (dir) end}
	end
	
	place_player_on_stairs(dir)

end

function map_moriya_shrine(dir)

	level.name = 'Moriya Shrine'
	level_connection = {up = function (dir) map_overworld(dir) end, down = function (dir) end}
	
	if not load_map() then
		local chunk = love.filesystem.load("map/moriya_shrine.lua")
		chunk()
	end
	
	map[40][16]:set_holding(Creature:new({name = 'Shopkeeper', team = 0, identify = true, char = '@', x = 7, y = 7, ai = 'shop'}))
	place_player_on_stairs(dir)

end

function map_random_overworld_encounter()

	local x = 0
	local y = 0
	local placed = 0
	local dog = false
	
	save_map_check()
	save_player()
	map_special_rooms = {}	
	
	overworld_coords = { x = player:get_x(), y = player:get_y() }

	--- surround map with trees
	for x = 1, map_width do
		for y = 1, map_height do
			if x == 1 or x == map_width then
				map[x][y] = Tile:new({name = 'Tree', char = 'T', block_sight = true, block_move = true, color = {r=0,g=255,b=0}, x = x, y = y})
			elseif y == 1 or y == map_height then
				map[x][y] = Tile:new({name = 'Tree', char = 'T', block_sight = true, block_move = true, color = {r=0,g=255,b=0}, x = x, y = y})
			else
				map[x][y] = Tile:new({name = 'Grass', char = ' .', block_sight = false, block_move = false, color = {r=0,g=255,b=0}, x = x, y = y})
			end
		end
	end
	
	--- random upstairs
	x = math.random(2, map_width-1)
	y = math.random(2, map_height)
	map[x][y] = Tile:new({name = 'UStairs', x = x, y = y})
	
	--- random player
	x = math.random(2, map_width-1)
	y = math.random(2, map_height)
	map_new_place_player(x, y)
	
	--- random monsters around player
	local dice = math.random(1, 3) 
	for i = 1, # game_monsters do
		if dice == 1 then
			if game_monsters[i].name == 'Wild Dog' then
				dog = game_monsters[i]
				message_add('You are surrounded by a large pack of wild dogs!') 
				break
			end
		elseif dice == 2 then
			if game_monsters[i].name == 'Little Oni' then
				dog = game_monsters[i]
				message_add('You are surrounded by clan of little onis!') 
				break
			end
		elseif dice == 3 then
			if game_monsters[i].name == 'Spirit' then
				dog = game_monsters[i]
				message_add('Spirits from the netherworld have surrounded you!') 
				break
			end
		end
	end
	if not dog then dog = game_monsters[# game_monsters] end
	
	placed = 0
	repeat
	
		x = math.random(player:get_x() - 8, player:get_x() + 8)
		y = math.random(player:get_y() - 8, player:get_y() + 8)
		
		if x < 1 then x = 1 end
		if x > map_width then x = map_width end
		if y < 1 then y = 1 end
		if y > map_height then y = map_height end
		
		if not map[x][y]:get_holding() and not map[x][y]:get_block_move() then
			dog['x'] = x
			dog['y'] = y
			map[x][y]:set_holding(Creature:new(dog))
			placed = placed + 1
		end
	
	until placed > math.random(9, 13)
	
	level.name = 'Wilderness'
	level.depth = 1
	level_connection = {up = function (dir) map_overworld(dir) end, down = function (dir) end }
	
	map_back_canvas_draw()
	player_fov()

end

function map_makai_entrance(dir)

	if level.name == 'Eerie Cave' or level.name == 'Makai Entrance' then
		if dir == 'down' then
			level.depth = level.depth + 1
		elseif dir == 'up' then
			level.depth = level.depth - 1
		end
	else
		level.depth = 1
	end
	
	level.name = 'Eerie Cave'
	level_connection = {up = function (dir) map_overworld(dir) end, down = function (dir) map_makai_entrance(dir) end}
	
	if level.depth == 1 then
		level.name = 'Eerie Cave'
		level.connection = {up = function (dir) map_overworld(dir) end, down = function (dir) end}
		if not load_map() then
			local chunk = love.filesystem.load('map/makai_entrance.lua')
			chunk()
		end
	end
	
	place_player_on_stairs(dir)

end

function map_eientei(dir)

	--- bamboo forest of the lost does not persist, but eientei levels do

	if level.name == 'Eientei' or level.name == 'Bamboo Forest' then
		if dir == 'down' then
			level.depth = level.depth + 1
		elseif dir == 'up' then
			level.depth = level.depth - 1
		end
	else
		level.depth = 1
	end
	
	level.name = 'Eientei'
	level_connection = {up = function (dir) map_overworld(dir) end, down = function (dir) map_eientei(dir) end}

	if level.depth == 1 then
		level_connection = {up = function (dir) map_overworld(dir) end, down = function (dir) map_eientei(dir) end}
		level.name = 'Bamboo Forest'
		if not load_map() then			
			map_gen_bamboo(map_width, map_height, true, true)			
			monster_maker(math.random(20,30))
			item_maker(math.random(10,20))
		end
	elseif level.depth > 1 and level.depth <= 3 then
		level_connection = {up = function (dir) map_eientei(dir) end, down = function (dir) map_eientei(dir) end}
		level.name = 'Bamboo Forest'
		if not load_map() then			
			map_gen_bamboo(map_width, map_height, true, true)			
			monster_maker(math.random(20,30))
			item_maker(math.random(10,20))
		end
	elseif level.depth == 4 then
		--- yard
		level.name = 'Eientei'
		level_connection = {up = function (dir) map_eientei() end, down = function (dir) map_eientei(dir) end}
		if not load_map() then					
			local chunk = love.filesystem.load('map/eientei_yard.lua')
			chunk()
			monster_maker(math.random(35,45))
			item_maker(math.random(20,30))
			--- Tewi Inaba
			local tewi = game_monsters[8]
			tewi['x'] = 10
			tewi['y'] = 17
			map[10][17]:set_holding(Creature:new(tewi))
		end
	elseif level.depth == 5 then
		--- entrance
		level.name = 'Eientei'
		level_connection = {up = function (dir) map_eientei() end, down = function (dir) map_eientei(dir) end}
		if not load_map() then
			local chunk = love.filesystem.load('map/eientei_entrance.lua')
			chunk()
			monster_maker(math.random(35, 45))
			item_maker(math.random(20, 30))
			--- down stairs
			local dice = math.random(1, 4)
			local placed = false
			local x = 0
			local y = 0
			repeat
				x = math.random(1, map_width)
				y = math.random(1, map_height)
				if not map[x][y]:get_block_move() then
					map[x][y] = Tile:new({name = 'DStairs', x = x, y = y})
					placed = true
				end
			until placed
			--- reisen u. inaba
			local rei = game_monsters[9]
			rei['x'] = 23
			rei['y'] = 18
			map[23][18]:set_holding(Creature:new(rei))
		end
	elseif level.depth == 6 then
		--- random rogue level
		level.name = 'Eientei'
		level_connection = {up = function (dir) map_eientei() end, down = function (dir) map_eientei(dir) end}
		if not load_map() then
			map_gen_rogue(map_width, map_height, true, true, 'rogue')	
			monster_maker(math.random(35, 45))
			item_maker(math.random(20, 30))
		end
	elseif level.depth == 7 then
		--- eirin's level
		level.name = 'Eientei'
		level_connection = {up = function (dir) map_eientei() end, down = function (dir) map_eientei(dir) end}
		if not load_map() then
			local chunk = love.filesystem.load("map/eientei_eirin.lua")
			chunk()
			monster_maker(math.random(15, 20))
			item_maker(math.random(5, 10))
			--- eirin
			local eir = game_monsters[10]
			eir['x'] = 42
			eir['y'] = 16
			map[42][16]:set_holding(Creature:new(eir))
		end		
	elseif level.depth == 8 then
		--- kaguya's level
		level.name = 'Eientei'
		level_connection = {up = function (dir) map_eientei() end, down = function (dir) end}
		if not load_map() then
			local chunk = love.filesystem.load("map/eientei_kaguya.lua")
			chunk()
			--- kaguya
			local kag = game_monsters[11]
			kag['x'] = 23
			kag['y'] = 15
			map[23][15]:set_holding(Creature:new(kag))
		end		
	end
	
	place_player_on_stairs(dir)

end

function map_youkai_dungeon(dir)

	if level.name == 'Youkai Forest' then
		if dir == 'down' then
			level.depth = level.depth + 1
		elseif dir == 'up' then
			level.depth = level.depth - 1
		end
	else
		level.depth = 1
	end
	
	level.name = 'Youkai Forest'
	
	if level.depth > 1 and level.depth <= 9 then
		level_connection = {up = function (dir) map_youkai_dungeon(dir) end, down = function (dir) map_youkai_dungeon(dir) end}
	elseif level.depth == 10 then
		level_connection = {up = function (dir) map_youkai_dungeon(dir) end, down = function (dir) end}
	elseif level.depth == 1 then
		level_connection = {up = function(dir) map_overworld() end, down = function (dir) map_youkai_dungeon(dir) end}
	end
	
	local dstairs = true
	if level.depth == 10 then dstairs = false end
	
	if not load_map() then
		map_gen_forest(map_width, map_height, true, dstairs)
		monster_maker(math.random(15,25))
		item_maker(math.random(10,20))
		place_player_on_stairs(dir)
	end
	
	if level.depth == 1 then
		--- Minoriko Aki
		local aki = game_monsters[6]	
		if check_unique(aki) then 
			aki['x'] = math.floor(map_width/2)
			aki['y'] = math.floor(map_height/2)
			map[math.floor(map_width/2)][math.floor(map_height/2)]:set_holding(Creature:new(aki)) 
		end
	elseif level.depth == 10 then
		--- Shizuha Aki
		local aki = game_monsters[7]	
		if check_unique(aki) then 
			aki['x'] = math.floor(map_width/2)
			aki['y'] = math.floor(map_height/2)
			map[math.floor(map_width/2)][math.floor(map_height/2)]:set_holding(Creature:new(aki)) 
		end
	end
	
end

function map_kourindou(dir)

	local chunk = love.filesystem.load('map/kourindou.lua')
	chunk()
	level = {name = 'Kourindou', depth = 1}
	level_connection = {up = function () map_overworld() end, down = nil}
	place_player_on_stairs(dir)

end

function map_human_village(dir)

	local chunk = love.filesystem.load('map/human_village.lua')
	chunk()
	level = {name = 'Human Village', depth = 1}
	level_connection = {up = function () map_overworld() end, down = nil}
	place_player_on_stairs(dir)

end

function map_sdm(dir)

	if dir == 'down' then
		level.depth = level.depth + 1
	elseif dir == 'up' then
		level.depth = level.depth - 1
	end

	if level.name == 'Overworld' then
		
		--- set up level info
		level = {name = 'Scarlet Devil Mansion', depth = 1}
		level_connection = {up = function (dir) map_overworld() end, down = function (dir) map_sdm(dir) end}
		
		--- load level
		if not load_map() then
			local chunk = love.filesystem.load('map/sdm_gate.lua')
			chunk()
		else
			place_player_on_stairs(dir)
		end
		
		--- hong meiling
		local hong = game_monsters[1]
		hong['x'] = 23
		hong['y'] = 16
		if check_unique(hong) then 
			map[23][16]:set_holding(Creature:new(hong)) 
			table.insert(unique_dead, hong.name)
		end
		
		map_new_place_player(23, 28)
		
	elseif level.name == 'Scarlet Devil Mansion' then
	
		if not load_map() then
		
			if level.depth == 1 then 
				--- gate
				level_connection = {up = function (dir) map_overworld() end, down = function (dir) map_sdm(dir) end}
				local chunk = love.filesystem.load('map/sdm_gate.lua')
				chunk()
				place_player_on_stairs(dir)
				
			elseif level.depth > 1 and level.depth < 6 then
				--- scarlet corridors
				level_connection = {up = function (dir) map_sdm(dir) end, down = function (dir) map_sdm(dir) end}
				local stairs = map_gen_rogue(map_width, map_height, true, true, 'sdm')					
				place_player_on_stairs(dir)
				
			elseif level.depth == 6 then
				--- library + patchy and koakuma
				level_connection = {up = function (dir) map_sdm(dir) end, down = function (dir) map_sdm(dir) end}
				local chunk = love.filesystem.load('map/sdm_library.lua')
				chunk()
				place_player_on_stairs(dir)
				
				--- patchy
				local patch = game_monsters[2]
				patch['x'] = 16
				patch['y'] = 26
				if check_unique(patch) then
					map[16][26]:set_holding(Creature:new(patch))
					table.insert(unique_dead, patch.name)
				end
				--- koa
				local koa = game_monsters[3]
				koa['x'] = 14
				koa['y'] = 25
				if check_unique(koa) then
					map[14][25]:set_holding(Creature:new(koa))
					table.insert(unique_dead, koa.name)
				end
				
			elseif level.depth == 7 then
				--- scarlet devil rooms and corridors
				level_connection = {up = function (dir) map_sdm(dir) end, down = function (dir) map_sdm(dir) end}
				local stairs = map_gen_rogue(map_width, map_height, true, true, 'sdm')					
				place_player_on_stairs(dir)
				
			elseif level.depth == 8 then
				--- sakuya's level
				level_connection = {up = function (dir) map_sdm(dir) end, down = function (dir) map_sdm(dir) end}
				local chunk = love.filesystem.load('map/sdm_sakuya.lua')
				chunk()
				place_player_on_stairs(dir)
				
				--- sakuya
				local sakuya = game_monsters[4]
				sakuya['x'] = 43
				sakuya['y'] = 27
				if check_unique(sakuya) then
					map[43][27]:set_holding(Creature:new(sakuya))
					table.insert(unique_dead, sakuya.name)
				end
				
			elseif level.depth == 9 then
				--- remi
				level_connection = {up = function (dir) map_sdm(dir) end, down = function (dir) map_sdm(dir) end}
				local chunk = love.filesystem.load('map/sdm_throneroom.lua')
				chunk()
				place_player_on_stairs(dir)
				
				--- remi
				local remi = game_monsters[5]
				remi['x'] = 43
				remi['y'] = 27
				if check_unique(remi) then
					map[43][27]:set_holding(Creature:new(remi))
					table.insert(unique_dead, remi.name)
				end
				
			elseif level.depth == 10 then
				--- flan flan
				level_connection = {up = function (dir) map_sdm(dir) end, down = function (dir) end}
				
			end
			
			monster_maker(math.random(15,25))
			item_maker(math.random(10,20))
			
		else
			place_player_on_stairs(dir)
		
		end
		
	end
	
end

function map_hakurei_shrine(dir)

	level = {name = 'Hakurei Shrine', depth = 1}
	level_connection = {up = function () map_overworld() end, down = nil}
	
	if not load_map() then
		local chunk = love.filesystem.load('map/hakurei_shrine.lua')
		chunk()
	end
			
	if dir == 'down' then
		map_new_place_player(24, 30)
	else
		map_new_place_player(24, 14)
	end
	
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
			if level.depth < 8 then
				stairs = map_gen_cave(map_width, map_height, true, true)
			else
				stairs = map_gen_cave(map_width, map_height, false, true)
			end
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
	
	--- if last level then place yin yang orb
	if level.depth == 8 then
		local placed = false
		repeat
			local x = math.random(1, map_width)
			local y = math.random(1, map_height)
			if not map[x][y]:get_block_move() then
				placed = true
				map[x][y]:set_items({Item:new(game_items[8])})
			end
		until placed
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
		
			local dstairs = true
			if level.depth == 4 then dstairs = false end
			stairs = map_gen_rogue(map_width, map_height, true, dstairs, 'dungeon')	
			
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
	
	--- if last cave level then the human elder's glasses
	if level.depth == 4 then
		local placed = false
		repeat
		
			local x = math.random(1, map_width)
			local y = math.random(1, map_height)
			print(x, y)
			if not map[x][y]:get_block_move() then
				map[x][y]:set_items({shop_find_game_item('Glasses')})
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

function map_gen_garden_of_the_sun(mapwidth, mapheight, dstairsd, ustairsd)

	--- fill the map with grass and sunflowers
	for x = 1, mapwidth do
		for y = 1, mapheight do
			if math.random(1, 100) <= 45 then
				map[x][y] = Tile:new({name = 'Grass', x = x, y = y, char = ' .', color = {r=0,g=255,b=0}})
			else
				map[x][y] = Tile:new({name = 'Sunflower', x = x, y = y, color = {r=255,g=252,b=77}, char = '*'})
			end
		end
	end
	
	--- Surround the map with unpassable trees
	for x = 1, mapwidth do
		map[x][1] = Tile:new({name = 'Tree', char = 'T', block_move = true, block_sight = true, color = {b=0,g=255,r=0}, x = x, y = 1})
		map[x][mapheight] = Tile:new({name = 'Tree', char = 'T', block_move = true, block_sight = true, color = {b=0,g=255,r=0}, x = x, y = mapheight})
	end
	for y = 1, mapheight do
		map[1][y] = Tile:new({name = 'Tree', char = 'T', block_move = true, block_sight = true, color = {b=0,g=255,r=0}, x = 1, y = y})
		map[mapwidth][y] = Tile:new({name = 'Tree', char = 'T', block_move = true, block_sight = true, color = {b=0,g=255,r=0}, x = mapwidth, y = y})
	end
	
	--- place stairs
	local ustairs = false
	local dstairs = false
	local stairs = {}
	repeat
	
		local x1 = math.random(1, mapwidth-7)
		local y1 = math.random(1, mapheight-7)
		local x2 = math.random(1, mapwidth-7)
		local y2 = math.random(1, mapheight-7)
		
		if not map[x1][y1]:get_block_move() and not map[x2][y2]:get_block_move() then
			if x1 ~= x2 and y1 ~= y2 then
				if ustairsd then map[x1][y1] = Tile:new({name = 'UStairs', x = x1, y = y1}) end
				if dstairsd then map[x2][y2] = Tile:new({name = 'DStairs', x = x2, y = y2}) end
				ustairs = true
				dstairs = true
			end
		end
		
		stairs = {up = {x = x1, y = y1}, down = {x = x2, y = y2}}
	
	until ustairs and dstairs
	
	return stairs

end

function map_gen_muenzuka(mapwidth, mapheight, dstairsd, ustairsd)

	local i = 0
	local j = 0
	local n = 0
	local s = 0
	local e = 0
	local w = 0
	local placed = 0

	--- flood the map with the floor
	for x = 1, mapwidth do
		for y = 1, mapheight do
			map[x][y] = Tile:new({name = 'Grass', char = ' .', color = {r=0,g=255,b=0}, x = x, y = y})
		end
	end
	
	--- place the purple tree things
	repeat
	
	i = math.random(1, map_width)
	j = math.random(1, map_height)
	
	for k = 1, 20 do
		n = math.random(1, 6)
		s = math.random(1, 6)
		e = math.random(1, 6)
		w = math.random(1, 6)
		
		local color={b=255,g=71,r=197}
		
		if n == 1 then
			i = i - 1
			if i < 1 then i = 1 end
			map[i][j] = Tile:new({name = 'Purple Cherry Blossom', char = 'T', block_move = false, block_sight = true, color = color, x = i, y = j})
		end
		if s == 1 then
			i = i + 1
			if i > map_width then i = map_width end
			map[i][j] = Tile:new({name = 'Purple Cherry Blossom', char = 'T', block_move = false, block_sight = true, color = color, x = i, y = j})
		end
		if e == 1 then
			j = j + 1
			if j > map_height then j = map_height end
			map[i][j] = Tile:new({name = 'Purple Cherry Blossom', char = 'T', block_move = false, block_sight = true, color = color, x = i, y = j})
		end
		if w == 1 then
			j = j - 1
			if j < 1 then j = 1 end
			map[i][j] = Tile:new({name = 'Purple Cherry Blossom', char = 'T', block_move = false, block_sight = true, color = color, x = i, y = j})
		end
	end
	
	placed = placed + 1
	
	until placed > 55
	
	--- poisonous higan 
	placed = 0
	repeat
	
		x = math.random(2, mapwidth - 1)
		y = math.random(2, mapheight - 1)
		
		if not map[x][y]:get_block_move() and not map[x][y]:get_block_sight() then
			map[x][y] = Tile:new({name = 'Poisonous Higan Flower', x = x, y = y, char = '*', color = {r=160,g=0,b=0}, block_move = false, block_sight = false})
			placed = placed + 1
		end
	
	until placed >= math.random(35, 45)
	
	--- Surround the map with unpassable trees
	for x = 1, mapwidth do
		map[x][1] = Tile:new({name = 'Purple Cherry Blossom', char = 'T', block_move = true, block_sight = true, color = {b=255,g=71,r=197}, x = x, y = 1})
		map[x][mapheight] = Tile:new({name = 'Purple Cherry Blossom', char = 'T', block_move = true, block_sight = true, color = {b=255,g=71,r=197}, x = x, y = mapheight})
	end
	for y = 1, mapheight do
		map[1][y] = Tile:new({name = 'Purple Cherry Blossom', char = 'T', block_move = true, block_sight = true, color = {b=255,g=71,r=197}, x = 1, y = y})
		map[mapwidth][y] = Tile:new({name = 'Purple Cherry Blossom', char = 'T', block_move = true, block_sight = true, color = {b=255,g=71,r=197}, x = mapwidth, y = y})
	end
	
	--- place stairs
	local ustairs = false
	local dstairs = false
	local stairs = {}
	repeat
	
		local x1 = math.random(1, mapwidth-7)
		local y1 = math.random(1, mapheight-7)
		local x2 = math.random(1, mapwidth-7)
		local y2 = math.random(1, mapheight-7)
		
		if not map[x1][y1]:get_block_move() and not map[x2][y2]:get_block_move() then
			if x1 ~= x2 and y1 ~= y2 then
				if ustairsd then map[x1][y1] = Tile:new({name = 'UStairs', x = x1, y = y1}) end
				if dstairsd then map[x2][y2] = Tile:new({name = 'DStairs', x = x2, y = y2}) end
				ustairs = true
				dstairs = true
			end
		end
		
		stairs = {up = {x = x1, y = y1}, down = {x = x2, y = y2}}
	
	until ustairs and dstairs
	
	return stairs
		
end

function map_gen_variety(mapwidth, mapheight, dstairsd, ustairsd)

	local x = 0
	local y = 0
	local width = 0
	local height = 0
	local rw = 0
	local rh = 0
	local placed = false
	local dice = 0
	local rooms = {}
	
	--- flood the map with walls
	for x = 1, mapwidth do
		for y = 1, mapheight do
			map[x][y] = Tile:new({name = 'Wall', x = x, y = y})
		end
	end
	
	--- divide the map up into grids
	width = math.floor( mapwidth / 3 )
	height = math.floor ( mapheight / 3 )
	for x = 1, 3 do
		for y = 1, 3 do
			table.insert(rooms, {sx = (x - 1) * width + 1, sy = (y - 1) * height + 1, w = width, h = height})
		end
	end
	
	--- place varying rooms in each square
	for i = 1, # rooms do
	
		print('---placing room ' .. i .. '---')
		
		placed = false
		repeat
			--- find the center of our room
			rw = math.random(5, 8)
			rh = math.random(5, 8)
			x = math.floor ( (rooms[i].sx + rooms[i].sx + rooms[i].w) / 2) + math.random( -1, 1)
			y = math.floor ( (rooms[i].sy + rooms[i].sy + rooms[i].h) / 2) + math.random( -1, 1)
			
			--- room type
			--- ROLL THE DIE ---
			--- ROLLLLLLLLAN ---
			dice = math.random(1, 8)
			
			--- square
			if dice == 1 then
				print('placing square room')
			
				for xx = x - math.floor(rw / 2), x + math.floor(rw / 2) do
					for yy = y - math.floor(rh / 2), y + math.floor(rh / 2) do
						map[xx][yy] = Tile:new({name = 'Floor', x = xx, y = yy})
					end
				end
				rooms[i]['cx'] = x
				rooms[i]['cy'] = y
				placed = true
				
			--- ray casting room
			elseif dice == 2 then
				print('placing ray casted room')
				
				map[x][y] = Tile:new({name = 'Floor', x = x, y = y})
				for angle = 1, 360, 1 do
					local dist = 0
					local dx = x + 0.5
					local dy = y + 0.5
					local xm = math.cos(angle)
					local ym = math.sin(angle)
					
					repeat
						dx = dx + xm
						dy = dy + ym
						dist = dist + 1
						if math.floor(dx) > mapwidth then break end
						if math.floor(dy) > mapheight then break end
						if math.floor(dx) < 1 then break end
						if math.floor(dy) < 1 then break end
						if math.floor(dx) < rooms[i].sx or math.floor(dx) > rooms[i].sx + rooms[i].w then break end
						if math.floor(dy) < rooms[i].sy or math.floor(dy) > rooms[i].sy + rooms[i].h then break end
						map[math.floor(dx)][math.floor(dy)] = Tile:new({name = 'Floor', x = math.floor(dx), y = math.floor(dy)})
					until dist > math.random(1, 5)
				
				end
				rooms[i]['cx'] = x
				rooms[i]['cy'] = y
				placed = true
				
			--- crossroads
			elseif dice == 3 then
				print('placing crossroads')
				
				map[x][y] = Tile:new({name = 'Floor', x = x, y = y})
				rooms[i]['cx'] = x
				rooms[i]['cy'] = y
				placed = true
				
			--- checkerboard
			elseif dice == 4 then
				print('placing checkerboard')
				
				local on = true
				for xx = x - math.floor(rw / 2), x + math.floor(rw / 2) do
					for yy = y - math.floor(rh / 2), y + math.floor(rh / 2) do
					
						if on then 
							map[xx][yy] = Tile:new({name = 'Floor', x = xx, y = yy}) 
							on = false
						else
							map[xx][yy] = Tile:new({name = 'Wall', x = xx, y = yy, tunnel = true})
							on = true
						end
						
						
					end
				end
				rooms[i]['cx'] = x
				rooms[i]['cy'] = y
				placed = true
				
			--- maze
			elseif dice == 5 or dice == 8 then
				print('placing maze')
				
				--- fill the area with floors and random walls
				for xx = x - math.floor(rw / 2), x + math.floor(rw / 2) do
					for yy = y - math.floor(rh / 2), y + math.floor(rh / 2) do
						if math.random(1, 100) <= 55 then
							map[xx][yy] = Tile:new({name = 'Floor', x = xx, y = yy})
						else
							map[xx][yy] = Tile:new({name = 'Wall', x = xx, y = yy, tunnel = true})
						end
					end
				end
				
				for i = 1, 4 do
					for xx = x - math.floor(rw / 2), x + math.floor(rw / 2) do
						for yy = y - math.floor(rh / 2), y + math.floor(rh / 2) do
							
							if xx > 1 and xx < mapwidth and yy > 1 and yy < mapheight then
								if map[xx][yy]:get_block_move() then
									if map_get_surrounding_blocked(xx, yy) >= 1 and
									   map_get_surrounding_blocked(xx, yy) <= 4 then
										map[xx][yy] = Tile:new({name = 'Wall', x = xx, y = yy, tunnel = true})
									else
										map[xx][yy] = Tile:new({name = 'Floor', x = xx, y = yy})
									end
								else
									if map_get_surrounding_blocked(xx, yy) == 3 then
										map[xx][yy] = Tile:new({name = 'Wall', x = xx, y = yy, tunnel = true})
									else
										map[xx][yy] = Tile:new({name = 'Floor', x = xx, y = yy})
									end
								end
							end
							
						end
					end
				end
				
				rooms[i]['cx'] = x
				rooms[i]['cy'] = y
				placed = true
				
			--- loop
			elseif dice == 6 then
				print('placing loop')
			
				for xx = x - math.floor(rw / 2), x + math.floor(rw / 2) do
					for yy = y - math.floor(rh / 2), y + math.floor(rh / 2) do
					
						map[xx][yy] = Tile:new({name = 'Wall', x = xx, y = yy, tunnel = true})
						if xx == x - math.floor(rw / 2) or xx == x + math.floor(rw / 2) then
							map[xx][yy] = Tile:new({name = 'Floor', x = xx, y = yy})
						end
						if yy == y - math.floor(rh / 2) or yy == y + math.floor(rh / 2) then
							map[xx][yy] = Tile:new({name = 'Floor', x = xx, y = yy})
						end

					end
				end
				rooms[i]['cx'] = x
				rooms[i]['cy'] = y
				placed = true
				
			--- chambers
			elseif dice == 7 then
				print('placing chambers')
				
				--- initial open room
				for xx = rooms[i].sx, rooms[i].sx + rooms[i].w do
					for yy = rooms[i].sy, rooms[i].sy + rooms[i].h do
						map[xx][yy] = Tile:new({name = 'Floor', x = xx, y = yy})
						if xx == rooms[i].sx or xx == rooms[i].sx + rooms[i].w then
							map[xx][yy] = Tile:new({name = 'Wall', x = xx, y = yy})
						end
						if yy == rooms[i].sy or yy == rooms[i].sy + rooms[i].h then
							map[xx][yy] = Tile:new({name = 'Wall', x = xx, y = yy})
						end
					end
				end
				
				--- chamber fortress in center
				for xx = rooms[i].sx + 3, rooms[i].sx + rooms[i].w - 3 do
					for yy = rooms[i].sy + 3, rooms[i].sy + rooms[i].h - 3 do
					
						if xx == rooms[i].sx + 3 or xx == rooms[i].sx + rooms[i].w - 3 then
							map[xx][yy] = Tile:new({name = 'Wall', x = xx, y = yy, tunnel = true})
						end
						if yy == rooms[i].sy + 3 or yy == rooms[i].sy + rooms[i].h - 3 then
							map[xx][yy] = Tile:new({name = 'Wall', x = xx, y = yy, tunnel = true})
						end
						
					end
				end
				
				--- main chamber door
				if math.random(1, 2) == 1 then
					dx = math.random(rooms[i].sx + 4, rooms[i].sx + rooms[i].w - 4)
					if math.random(1, 2) == 1 then
						map[dx][rooms[i].sy + 3] = Tile:new({name = 'Floor', x = dx, y = rooms[i].sy + 3})
					else
						map[dx][rooms[i].sy + rooms[i].h - 3] = Tile:new({name = 'Floor', x = dx, y = rooms[i].sy + rooms[i].h - 3})
					end
				else
					dy = math.random(rooms[i].sy + 4, rooms[i].sy + rooms[i].h - 4)
					if math.random(1, 2) == 1 then
						map[rooms[i].sx + 3][dy] = Tile:new({name = 'Floor', x = rooms[i].sx + 3, y = dy})
					else
						map[rooms[i].sx + rooms[i].w - 3][dy] = Tile:new({name = 'Floor', x = rooms[i].sx + rooms[i].w - 3, y = dy})
					end
				end
				
				--- divide the chamber up
				local walls = 0
				local door = false
				local prob = 0
				
				repeat
					dx = math.random(rooms[i].sx + 6, rooms[i].sx + rooms[i].w - 6)
					if map[dx][rooms[i].sy + 3]:get_block_move() and not map[dx-1][rooms[i].sy + 4]:get_block_move() 
					   and not map[dx+1][rooms[i].sy + 4]:get_block_move() and not map[dx-2][rooms[i].sy + 4]:get_block_move()
					   and not map[dx+2][rooms[i].sy + 4]:get_block_move() then
						for yy = rooms[i].sy + 4, rooms[i].sy + rooms[i].h - 4 do
							map[dx][yy] = Tile:new({name = 'Wall', x = dx, y = yy, tunnel = true})
							prob = prob + 15
							if yy > rooms[i].sy + 4 and yy < rooms[i].sy + rooms[i].h - 4 and not door and math.random(1, 100) <= 45 + prob then
								map[dx][yy] = Tile:new({name = 'Floor', x = dx, y = yy})
								door = true
							end
						end
						walls = walls + 1
						door = false
					end
				until walls >= 3
				
				rooms[i]['cx'] = x
				rooms[i]['cy'] = y
				placed = true
			
			end
			
		until placed
		
	end
	
	--- place some small square rooms that aren't restricted by the grid
	local rmp = 0
	local can_place = false
	repeat
	
		x = math.random(2, mapwidth - 7)
		y = math.random(2, mapheight - 7)
		w = math.random(3, 6)
		h = math.random(3, 6)
		
		can_place = true
		for xx = x, x + w do
			for yy = y, y + h do
				if not map[xx][yy]:get_block_move() then can_place = false end
			end
		end
		
		if can_place then
			for xx = x, x + w do
				for yy = y, y + h do
					map[xx][yy] = Tile:new({name = 'Floor', x = xx, y = yy})
				end
			end
			rmp = rmp + 1
			table.insert(rooms, {sx = x, sy = y, w = w, h = h, cx = math.floor(x + w / 2), cy = math.floor(y + h / 2)})
		end
	
	until rmp >= 4
	
	--- place tunnels between rooms
	for num = 1, 3 do
		for i = 1, # rooms do
			
			local k = # rooms + 1
			local dice = math.random(1, 4)
			
			if dice == 1 then 
				k = i - 1
			elseif dice == 2 then
				k = i + 3
			elseif dice == 3 then
				k = i + 1
			elseif dice == 4 then 
				k = i - 3
			end
			
			if k < 1 then k = 1 end
			if k > # rooms then k = # rooms end
			
			local xdif = 0
			local ydif = 0
		
			if math.random(1, 1) == 1 then
			
				xdif = 0
				ydif = 0
			
				for xx = math.min(rooms[i].cx, rooms[k].cx), math.max(rooms[i].cx, rooms[k].cx) do
					if not map[xx + xdif][rooms[i].cy + ydif]:get_tunnel() then
						map[xx + xdif][rooms[i].cy + ydif] = Tile:new({name = 'Floor', x = xx + xdif, y = rooms[i].cy + ydif})
					end
					
					if math.random(1, 100) <= 15 then
						ydif = ydif + math.random(-1, 1)
					end
					
				end
				
				for yy = math.min(rooms[i].cy, rooms[k].cy), math.max(rooms[i].cy, rooms[k].cy) do
					if not map[rooms[k].cx + xdif][yy + ydif]:get_tunnel() then
						map[rooms[k].cx + xdif][yy + ydif] = Tile:new({name = 'Floor', x = rooms[k].cx + xdif, y = yy + ydif})
					end
					
					if math.random(1, 100) <= 15 then
						xdif = xdif + math.random(-1, 1)
					end
					
				end
				
			else
			
				xdif = 0
				ydif = 0
			
				for yy = math.min(rooms[i].cy, rooms[k].cy), math.max(rooms[i].cy, rooms[k].cy) do
					if not map[rooms[i].cx + xdif][yy + ydif]:get_tunnel() then
						map[rooms[i].cx + xdif][yy + ydif] = Tile:new({name = 'Floor', x = rooms[i].cx + xdif, y = yy + ydif})
					end
					
					if math.random(1, 100) <= 15 then
						ydif = ydif + math.random(-1, 1)
					end
					
				end
				
				xdif = 0
				ydif = 0
				
				for xx = math.min(rooms[i].cx, rooms[k].cx), math.max(rooms[i].cx, rooms[k].cx) do
					if not map[xx + xdif][rooms[k].cy + ydif]:get_tunnle() then
						map[xx + xdif][rooms[k].cy + ydif] = Tile:new({name = 'Floor', x = xx + xdif, y = rooms[k].cy + ydif})
					end
					
					if math.random(1, 100) <= 15 then
						xdif = xdif + math.random(-1, 1)
					end
					
				end
				
			end
			
		end
	end	
	
	--- surround map with walls
	for x = 1, mapwidth do
		map[x][1] = Tile:new({name = 'Wall', x = x, y = 1})
		map[x][mapheight] = Tile:new({name = 'Wall', x = x, y = mapheight})
	end
	for y = 1, mapheight do
		map[1][y] = Tile:new({name = 'Wall', x = 1, y = y})
		map[mapwidth][y] = Tile:new({name = 'Wall', x = mapwidth, y = y})
	end
	
	--- place stairs
	local ustairs = false
	local dstairs = false
	local stairs = {}
	repeat
	
		local x1 = math.random(1, mapwidth-7)
		local y1 = math.random(1, mapheight-7)
		local x2 = math.random(1, mapwidth-7)
		local y2 = math.random(1, mapheight-7)
		
		if not map[x1][y1]:get_block_move() and not map[x2][y2]:get_block_move() then
			if x1 ~= x2 and y1 ~= y2 then
				if ustairsd then map[x1][y1] = Tile:new({name = 'UStairs', x = x1, y = y1}) end
				if dstairsd then map[x2][y2] = Tile:new({name = 'DStairs', x = x2, y = y2}) end
				ustairs = true
				dstairs = true
			end
		end
		
		stairs = {up = {x = x1, y = y1}, down = {x = x2, y = y2}}
	
	until ustairs and dstairs
	
	return stairs

end

function map_gen_cave(width, height, dstairsd, ustairsd)

	--- clear the map
	for x = 1, width do
		for y = 1, height do
			local dchar = '#'
			local dice = math.random(1, 100)
			if dice >= 1 and dice < 40 then
				dchar = ' |'
			elseif dice >= 40 and dice < 80 then
				dchar = '-'
			else
				dchar = '#'
			end
			map[x][y] = Tile:new({name = 'CaveWall', x = x, y = y, char = dchar, color = {b=2,g=70,r=140}, block_move = true, block_sight = true})
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
				if ustairsd then map[x1][y1] = Tile:new({name = 'UStairs', x = x1, y = y1}) end
				if dstairsd then map[x2][y2] = Tile:new({name = 'DStairs', x = x2, y = y2}) end
				ustairs = true
				dstairs = true
			end
		end
		
		stairs = {up = {x = x1, y = y1}, down = {x = x2, y = y2}}
	
	until ustairs and dstairs
	
	return stairs

end

function map_gen_forest(width, height, p_ustairs, p_dstairs)
	
	local n = 0
	local s = 0
	local e = 0
	local w = 0
	
	local placed = 0
	
	local i = math.floor(width/2)
	local j = math.floor(height/2)
	
	--- flood map with floor
	for x = 1, width do
		for y = 1, height do
			local tchar = ' .'
			map[x][y] = Tile:new({name = 'LeafFloor', char = tchar, block_move = false, block_sight = false, color = {r=184, g=157, b=83}, x = x, y = y})
		end
	end

	--- grow trees in clusters
	repeat
	
	i = math.random(1, map_width)
	j = math.random(1, map_height)
	
	for k = 1, 20 do
		n = math.random(1, 6)
		s = math.random(1, 6)
		e = math.random(1, 6)
		w = math.random(1, 6)
		
		local color = {r=209, g=61, b=61}
		local dice = math.random(1, 3)
		if dice == 1 then
			color = {r=201, g=119, b=46}
		elseif dice == 2 then
			color = {r=186, g=153, b=52}
		else
			color = {r=209, g=61, b=61}
		end
		
		if n == 1 then
			i = i - 1
			if i < 1 then i = 1 end
			map[i][j] = Tile:new({name = 'AutumnTree', char = 'T', block_move = false, block_sight = true, color = color, x = i, y = j})
		end
		if s == 1 then
			i = i + 1
			if i > map_width then i = map_width end
			map[i][j] = Tile:new({name = 'AutumnTree', char = 'T', block_move = false, block_sight = true, color = color, x = i, y = j})
		end
		if e == 1 then
			j = j + 1
			if j > map_height then j = map_height end
			map[i][j] = Tile:new({name = 'AutumnTree', char = 'T', block_move = false, block_sight = true, color = color, x = i, y = j})
		end
		if w == 1 then
			j = j - 1
			if j < 1 then j = 1 end
			map[i][j] = Tile:new({name = 'AutumnTree', char = 'T', block_move = false, block_sight = true, color = color, x = i, y = j})
		end
	end
	
	placed = placed + 1
	
	until placed > 55
	
	--- place some fallen logs around
	local placed = 0
	
	repeat
	
		local x = math.random(3, map_width - 3)
		local y = math.random(3, map_height - 3)
		local length = math.random(2, 3)
		local dice = math.random(1, 2)
		local tchar = '='
		
		if dice == 1 then
			tchar = '='
		elseif dice == 2 then
			tchar = '[]'
		end
		
		if not map[x][y]:get_block_move() then
			map[x][y] = Tile:new({name = 'FallenLog', char = tchar, x = x, y = y, block_move = true, block_sight = false, color = {r=129, g=96, b=10}})
			if dice == 1 then
				map[x+1][y] = Tile:new({name = 'FallenLog', char = tchar, x = x+1, y = y, block_move = true, block_sight = false, color = {r=129, g=96, b=10}})
				if length == 3 then
					map[x+2][y] = Tile:new({name = 'FallenLog', char = tchar, x = x+2, y = y, block_move = true, block_sight = false, color = {r=129, g=96, b=10}})
				end
			elseif dice == 2 then
				map[x][y+1] = Tile:new({name = 'FallenLog', char = tchar, x = x, y = y+1, block_move = true, block_sight = false, color = {r=129, g=96, b=10}})
				if length == 3 then
					map[x][y+2] = Tile:new({name = 'FallenLog', char = tchar, x = x, y = y+2, block_move = true, block_sight = false, color = {r=129, g=96, b=10}})
				end
			end
			placed = placed + 1
		end
	
	until placed > 15
	
	--- surround map with trees now
	for x = 1, width do
		map[x][1] = Tile:new({name = 'AutumnTree', char = 'T', block_move = true, block_sight = true, color = {r=209, g=61, b=61}, x = x, y = 1})
		map[x][height] = Tile:new({name = 'AutumnTree', char = 'T', block_move = true, block_sight = true, color = {r=209, g=61, b=61}, x = x, y = height})
	end
	for y = 1, height do
		map[1][y] = Tile:new({name = 'AutumnTree', char = 'T', block_move = true, block_sight = true, color = {r=209, g=61, b=61}, x = 1, y = y})
		map[width][y] = Tile:new({name = 'AutumnTree', char = 'T', block_move = true, block_sight = true, color = {r=209, g=61, b=61}, x = width, y = y})
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
				if p_ustairs then map[x1][y1] = Tile:new({name = 'UStairs', x = x1, y = y1}) end
				if p_dstairs then map[x2][y2] = Tile:new({name = 'DStairs', x = x2, y = y2}) end
				ustairs = true
				dstairs = true
			end
		end
		
		stairs = {up = {x = x1, y = y1}, down = {x = x2, y = y2}}
	
	until ustairs and dstairs
	
	return stairs
	
end

function map_gen_bamboo(width, height, p_ustairs, p_dstairs)

	local new_map = {}
	
	--- make the new map
	new_map = {}
	for x = 1, width do
		new_map[x] = {}
		for y = 1, height do
			new_map[x][y] = {}
		end
	end

	--- flood initial map
	for x = 1, width do
		for y = 1, height do
			map[x][y] = Tile:new({name = 'Grass', color = {r=255,g=255,b=255}, block_sight = false, block_move = false, char = 'T', x = x, y = y})
		end
	end
	
	--- place initial bamboo tress
	local placed = 0
	repeat
	
		local x = math.random(2, width-1)
		local y = math.random(2, height-1)
		
		if not map[x][y]:get_block_move() then
			placed = placed + 1
			map[x][y] = Tile:new({name = 'BambooShoot', color = {r=153,g=224,b=153}, block_sight = true, block_move = true, char = 't', x = x, y = y})
		end
	
	until placed >= math.floor( (width * height) * 0.45 )
	
	--- cellular automata generator
	for i = 1, 6 do
		
		for x = 1, width do
			for y = 1, height do			
				if map[x][y]:get_block_move() then
					new_map[x][y] = Tile:new({name = 'BambooShoot', color = {r=153,g=224,b=153}, block_sight = true, block_move = true, char = 't', x = x, y = y})
				else
					new_map[x][y] = Tile:new({name = 'Grass', color = {r=0,g=255,b=0}, block_sight = false, block_move = false, char = ' .', x = x, y = y})		
				end
			end
		end
		
		for x = 2, width-1 do
			for y = 2, height-1 do
				
				if i >= 1 and i <= 2 then
					if map_get_surrounding_blocked(x, y) >= 5 or map_get_surrounding_blocked(x, y) == 0 then
						new_map[x][y] = Tile:new({name = 'BambooShoot', color = {r=153,g=224,b=153}, block_sight = true, block_move = true, char = 't', x = x, y = y})
					else
						new_map[x][y] = Tile:new({name = 'Grass', color = {r=0,g=255,b=0}, block_sight = false, block_move = false, char = ' .', x = x, y = y})					
					end
				else
					if map_get_surrounding_blocked(x, y) >= 5 or map_get_surrounding_blocked(x, y) == 0 then
						new_map[x][y] = Tile:new({name = 'BambooShoot', color = {r=153,g=224,b=153}, block_sight = true, block_move = true, char = 't', x = x, y = y})
					else
						new_map[x][y] = Tile:new({name = 'Grass', color = {r=0,g=255,b=0}, block_sight = false, block_move = false, char = ' .', x = x, y = y})					
					end
				end
			
			end
		end
		
		for x = 1, width do
			for y = 1, height do
				if new_map[x][y]:get_block_move() then
					map[x][y] = Tile:new({name = 'BambooShoot', color = {r=153,g=224,b=153}, block_sight = true, block_move = true, char = 't', x = x, y = y})
				else
					map[x][y] = Tile:new({name = 'Grass', color = {r=0,g=255,b=0}, block_sight = false, block_move = false, char = ' .', x = x, y = y})		
				end
			end
		end
			
	end
	
	--- replace grass with dirt 
	for x = 2, width-2 do
		for y = 2, height-2 do
			if not map[x][y]:get_block_move() and map_get_surrounding_blocked(x, y) == 0 then
				map[x][y] = Tile:new({name = 'dirt', color = {r=149,g=107,b=64}, block_sight = false, block_move = false, char = ' .', x = x, y = y})
			end
		end
	end
	
	--- surround map with walls
	for x = 1, width do
		map[x][1] = Tile:new({name = 'Tree', x = x, y = 1})
		map[x][height] = Tile:new({name = 'Tree', x = x, y = height})
	end
	for y = 1, height do
		map[1][y] = Tile:new({name = 'Tree', x = 1, y = y})
		map[width][y] = Tile:new({name = 'Tree', x = width, y = y})
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
				if p_ustairs then map[x1][y1] = Tile:new({name = 'UStairs', x = x1, y = y1}) end
				if p_dstairs then map[x2][y2] = Tile:new({name = 'DStairs', x = x2, y = y2}) end
				ustairs = true
				dstairs = true
			end
		end
		
		stairs = {up = {x = x1, y = y1}, down = {x = x2, y = y2}}
	
	until ustairs and dstairs		
	return stairs
	
end

function map_gen_rogue(width, height, p_ustairs, p_dstairs, pal)
	
	local rooms = {}
	local rooms_placed = 0
	local UStairs = {}
	local DStairs = {}
	local wall_color = {r = 255, g = 255, b = 255}
	local floor_color = {r = 255, g = 255, b = 255}
	
	if pal == 'sdm' then 
		wall_color = {r=222,b=138,g=191}
		floor_color = {r=110,b=8,g=8}
	elseif pal == 'dungeon' then
		wall_color = {r=255,b=255,g=255}
		floor_color = {r=200,b=200,g=200}
	end
	
	--- clear the map
	for x = 1, width do
		for y = 1, height do
			map[x][y] = Tile:new({name = 'RogueWall', color = wall_color, block_sight = true, block_move = true, char = '#', x = x, y = y})
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
					map[dx][dy] = Tile:new({name = 'RogueFloor', color = floor_color, block_sight = false, block_move = false, char = ' .', x = dx, y = dy})					
				end
			end
			--- room decorative walls
			for dx = x, x + w do
				map[dx][y] = Tile:new({name = 'Dwall', x = dx, y = y, color = wall_color, char = '-', block_sight = true, block_move = true})
				map[dx][y+h] = Tile:new({name = 'Dwall', x = dx, y = y+h, color = wall_color, char = '-', block_sight = true, block_move = true})
			end
			for dy = y, y + h do
				map[x][dy] = Tile:new({name = 'Dwall', x = x, y = dy, color = wall_color, char = ' |', block_sight = true, block_move = true})
				map[x+w][dy] = Tile:new({name = 'Dwall', x = x+w, y = dy, color = wall_color, char = ' |', block_sight = true, block_move = true})
			end
			map[x][y] = Tile:new({name = 'Dwall', x = x, y = y, color = wall_color, char = '+', block_sight = true, block_move = true})
			map[x+w][y] = Tile:new({name = 'Dwall', x = x+w, y = y, color = wall_color, char = '+', block_sight = true, block_move = true})
			map[x][y+h] = Tile:new({name = 'Dwall', x = x, y = y+h, color = wall_color, char = '+', block_sight = true, block_move = true})
			map[x+w][y+h] = Tile:new({name = 'Dwall', x = x+w, y = y+h, color = wall_color, char = '+', block_sight = true, block_move = true})
			
			table.insert(rooms, {x = x, y = y, w = w, h = h})
			rooms_placed = rooms_placed + 1
		end
	
	until rooms_placed > math.random(6, 8)
	
	--- special rooms, cant be in either stair room
	for i = 2, # rooms - 1 do
		if math.random(1, 100) <= 10 + (level.depth * 5) then
		
			local dice = math.random(1, 3)
			
			--- flood floor with walls first
			for xx = rooms[i].x + 1, rooms[i].x + rooms[i].w - 1 do
				for yy = rooms[i].y + 1, rooms[i].y + rooms[i].h - 1 do	
					map[xx][yy] = Tile:new({name = 'Wall', x = xx, y = yy})
				end
			end
			
			--- grass room
			if dice == 1 then
				--- add room to list for message
				table.insert(map_special_rooms, {x = rooms[i].x, y = rooms[i].y, w = rooms[i].w, h = rooms[i].h, enter = false, message = "You enter an underground garden."})
				for xx = rooms[i].x, rooms[i].x + rooms[i].w do
					for yy = rooms[i].y, rooms[i].y + rooms[i].h do						
						--- wall
						if xx == rooms[i].x or xx == rooms[i].x + rooms[i].w then
							map[xx][yy] = Tile:new({name = 'Tree', char = 'T', color = {r=0, g=255, b=0}, block_sight = true, block_move = true, x = xx, y = yy})
						elseif yy == rooms[i].y or yy == rooms[i].y + rooms[i].h then				
							map[xx][yy] = Tile:new({name = 'Tree', char = 'T', color = {r=0, g=255, b=0}, block_sight = true, block_move = true, x = xx, y = yy})							
						end
						--- floor
						if xx > rooms[i].x and xx < rooms[i].x + rooms[i].w and yy > rooms[i].y and yy < rooms[i].y + rooms[i].h then
							map[xx][yy] = Tile:new({name = 'Grass', char = " .", color = {r=0, g=255, b=0}, block_sight = false, block_move = false, x = xx, y = yy})
						end						
					end
				end
			end
			
			--- water room
			if dice == 2 then
				--- add room to list for message
				table.insert(map_special_rooms, {x = rooms[i].x, y = rooms[i].y, w = rooms[i].w, h = rooms[i].h, enter = false, message = "You enter an underground pool."})
				for xx = rooms[i].x, rooms[i].x + rooms[i].w do
					for yy = rooms[i].y, rooms[i].y + rooms[i].h do						
						--- wall
						if xx == rooms[i].x or xx == rooms[i].x + rooms[i].w then
							map[xx][yy] = Tile:new({name = 'Wall', x = xx, y = yy})
						elseif yy == rooms[i].y or yy == rooms[i].y + rooms[i].h then				
							map[xx][yy] = Tile:new({name = 'Wall', x = xx, y = yy})							
						end
						--- floor
						if xx > rooms[i].x and xx < rooms[i].x + rooms[i].w and yy > rooms[i].y and yy < rooms[i].y + rooms[i].h then
							map[xx][yy] = Tile:new({name = 'Floor', x = xx, y = yy})
							if xx > rooms[i].x + 1 and xx < rooms[i].x + rooms[i].w - 1 and yy > rooms[i].y + 1 and yy < rooms[i].y + rooms[i].h - 1 then
								map[xx][yy] = Tile:new({name = 'Water', x = xx, y = yy})
							end						
						end						
					end
				end
			end
			
			--- foggy room
			if dice == 3 then
				--- add room to list for message
				table.insert(map_special_rooms, {x = rooms[i].x, y = rooms[i].y, w = rooms[i].w, h = rooms[i].h, enter = false, message = "This room is covered by a thick layer of fog."})
				for xx = rooms[i].x, rooms[i].x + rooms[i].w do
					for yy = rooms[i].y, rooms[i].y + rooms[i].h do						
						--- floor
						if xx > rooms[i].x and xx < rooms[i].x + rooms[i].w and yy > rooms[i].y and yy < rooms[i].y + rooms[i].h then
							map[xx][yy] = Tile:new({name = 'Fog', char = "█", color = {r=175, g=175, b=175}, block_sight = true, block_move = false, x = xx, y = yy})
						end						
					end
				end
			end
			
			break
			
		end
	end

	--- place corridors between rooms, and add in stairs when appropriate
	for i = 1, # rooms - 1 do
		--- corridors
		local x1 = math.floor(rooms[i].x + rooms[i].w / 2)
		local y1 = math.floor(rooms[i].y + rooms[i].h / 2)
		local x2 = math.floor(rooms[i+1].x + rooms[i+1].w / 2)
		local y2 = math.floor(rooms[i+1].y + rooms[i+1].h / 2)
		for x = math.min(x1, x2), math.max(x1, x2) do
			if map[x][y1]:get_block_move() then map[x][y1] = Tile:new({name = "RogueFloor", char = " .", color = floor_color, block_sight = false, block_move = false, x = x, y = y1}) end
		end
		for y = math.min(y1, y2), math.max(y1, y2) do
			if map[x2][y]:get_block_move() then map[x2][y] = Tile:new({name = "RogueFloor", char = " .", color  = floor_color, block_sight = false, block_move = false, x = x2, y = y}) end
		end
		
		--- stairs
		if p_ustairs and i == 1 then
			map[x1][y1] = Tile:new({name = 'UStairs', x = x1, y = y1})
			UStairs = {x = x1, y = y1}
		elseif p_dstairs and i == # rooms - 1 then
			map[x1][y1] = Tile:new({name = 'DStairs', x = x1, y = y1})
			DStairs = {x = x1, y = y1}
		end
	end
	
	local stairs = {up = UStairs, down = DStairs}
	return stairs

end

function check_unique(mon) 

	local good = true
	for i = 1, # unique_dead do
		if unique_dead[i] == mon.name then
			good = false
		end
	end
	return good

end

function mon_gen_machine()

	for i = 1, # overworld_levels do
		if overworld_levels[i].name == level.name and overworld_levels[i].mon_gen then
			mon_gen(overworld_levels[i].mon_gen)
		end
	end

end

function mon_gen(level)

	if math.random(2000 - (level * 4)) <= level + player_level then

		local placed = false
		repeat
		
			local x = math.random(2, 45)
			local y = math.random(2, 32)
			
			if not map[x][y]:get_block_move() and not map[x][y]:get_lit() then
				local mon = map_random_monster(player_level)
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
		
		if not map[x][y]:get_block_move() and map[x][y]:get_char() ~= '>' and map[x][y]:get_char() ~= '<' then
			local monster = map_random_monster(player_level)
			monster['x'] = x
			monster['y'] = y
			map[x][y]:set_holding(Creature:new(monster))
			
			if monster.name == 'Wild Dog' or monster.name == 'Rabbit' then 
				for xx = x - 2, x + 2 do
					for yy = y - 2, y + 2 do
						if xx > 1 and xx < map_width and yy > 1 and yy < map_height and not map[xx][yy]:get_block_move() and not map[xx][yy]:get_holding() and math.random(1, 100) <= 25 then
							monster['x'] = xx
							monster['y'] = yy
							map[xx][yy]:set_holding(Creature:new(monster))
						end
					end
				end
			end
			
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

function map_random_monster(lvl)

	local monlevel = math.floor( (player_level + level.depth) / 2)
	local mons = {}
	local chance = 0
	local dice_max = 0
	local dice = 0
	
	for i = 1, # overworld_levels do
		if overworld_levels[i].name == level.name and overworld_levels[i].mon_gen then
			monlevel = overworld_levels[i].mon_gen
			break
		end
	end

	for i = 1, # game_monsters do
		if game_monsters[i].level <= monlevel and game_monsters[i].rand_gen then
			table.insert(mons, game_monsters[i])
		end
	end
	
	if # mons == 0 then
		table.insert(mons, game_monsters[10])
	end
		
	for i = 1, # mons do
		chance = chance + mons[i].level
	end
	dice_max = chance
	chance = 0
	
	dice = math.random(1, dice_max)
	for i = 1, # mons do
		chance = chance + mons[i].level
		if dice <= chance and mons[dice] then
			return mons[dice]
		end
	end
	
	return mons[1]
	
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
		
	elseif map[player:get_x()][player:get_y()]:get_name() == 'KeyStone' then
		message_add("You don't have the key that fits into this stone.")
		
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
	
	if danmaku then
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle('fill', ascii_draw_point(danmaku.x), ascii_draw_point(danmaku.y), char_width, char_width)
		love.graphics.setColor(255, 255, 255, 255)
	end
	if # ascii_effects > 0 then
		for i = 1, # ascii_effects do
			if ascii_effects[i].delay < 1 then
				love.graphics.setColor(0, 0, 0, 255)
				love.graphics.rectangle('fill', ascii_draw_point(ascii_effects[i].x), ascii_draw_point(ascii_effects[i].y), char_width, char_width)
				love.graphics.setColor(255, 255, 255, 255)
			end
		end
	end
	
	
	love.graphics.setCanvas()
	love.graphics.draw(map_back_canvas)
	love.graphics.draw(map_canvas)
	
end

function map_back_canvas_update(x, y)

	love.graphics.setCanvas(map_back_canvas)
	love.graphics.setFont(game_font)
	love.graphics.setBlendMode('alpha')
	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', ascii_draw_point(x), ascii_draw_point(y), char_width, char_width)
	map[x][y]:draw_ascii()
	love.graphics.setCanvas()
	
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

function map_unlit_all()

	local start_x = 1
	local start_y = 1
	local end_x = map_width
	local end_y = map_height

	for x = start_x, end_x do
		for y = start_y, end_y do
			if map[x][y] and map[x][y]:get_lit() then
				map[x][y]:set_unlit()
				map[x][y]:set_seen()
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