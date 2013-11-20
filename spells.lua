game_spells = {	{name = 'Omamori of Health', mp_cost = 75, func = function () player:heal(35) end},
				{name = 'Ofuda of Protection', mp_cost = 50, func = function () add_modifier({name = 'Protection', turn = 60, armor = 5}) end},
				{name = 'Power of Hachiman', mp_cost = 55, func = function () add_modifier({name = 'Power', turn = 60, damage = 50}) end, level = 3},
				{name = 'Speed of Fujin', mp_cost = 75, func = function () add_modifier({name = 'Speed', turn = 70, speed = 5}) end, level = 5},
				{name = 'Persuasion Needles', mp_cost = 25, func = function () add_modifier({name = 'Needles', turn = 60, bullet = 2}) end},
				{name = 'Border of Distance', mp_cost = 55, func = function () add_modifier({name = 'Distancer', turn = 70, speed = 5, armor = -5, damage = -25}) end},
				{name = 'Circular Danmaku', mp_cost = 40, func = function () circle_danmaku(player:get_x(), player:get_y(), 8) end},
				{name = 'High Frequency Danmaku', mp_cost = 55, func = function () add_modifier({name = 'Hi Freq', turn = 60, danmaku_explosive = 2}) end},
				{name = 'Fantasy Seal Spread', mp_cost = 200, func = function () fantasy_seal(player:get_x(), player:get_y(), 5, 'int') end},
				{name = 'Merciless Purification Rod', mp_cost = 250, func = function () fantasy_seal(player:get_x(), player:get_y(), 1, 'str') end},
				{name = 'Border of Danmaku', mp_cost = 75, func = function () border_shoot(player:get_x(), player:get_y()) end},
				{name = 'Border Jumper', mp_cost = 15, func = function () border_jumper(player:get_x(), player:get_y(), 8) end},
				}
				
function border_jumper(sx, sy, range)

	local sx = sx
	local sy = sy
	local x = sx
	local y = sy
	local ex = 0
	local ey = 0
	local dx = player_last_move.x
	local dy = player_last_move.y
	local air = true
	
	for i = 1, range do
		
		x = x + dx
		y = y + dy
		
		if map[x][y]:get_block_move() or map[x][y]:get_holding() then
			air = false
			x = x - dx
			y = y - dy
		end
		
		table.insert(ascii_effects, {char = '@', time = 3 + range * 3 - i, delay = i * 3 - 3, x = x, y = y, color = function () love.graphics.setColor(0, 100, 255, 255) end})
		
		ex = x
		ey = y
		
	end
	
	table.insert(ascii_effects, {char = ' ', time = range * 3, delay = 0, x = x, y = y, color = function () love.graphics.setColor(0, 100, 255, 255) end})
	
	map_unlit_all()
	map[player:get_x()][player:get_y()]:set_holding(nil)
	map_new_place_player(ex, ey)
	player_fov()

end
				
function border_shoot(sx, sy)

	local sx = sx 
	local sy = sy 
	local ex = 0
	local ey = 0
	local x = 0
	local y = 0
	local dam = math.random(player_stats.int * 15)
	local air = true
	
	sx = sx - 5 * player_last_move.x
	sy = sy - 5 * player_last_move.y
	
	if sx < 1 then sx = 1 end
	if sy < 1 then sy = 1 end
	if sx > map_width then sx = map_width end
	if sy > map_height then sy = map_height end
	
	x = sx
	y = sy
	
	for i = 1, 5 do
		x = x + player_last_move.x
		y = y + player_last_move.y
		
		if map[x][y]:get_holding() then
			map[x][y]:get_holding():take_dam(dam, 'pure', 'Border Bullet')
			air = false
		end
		
		if map[x][y]:get_block_move() then 
			air = false
		end
		
		ex = x
		ey = y
		
		if not air then break end
	end
	
	table.insert(ascii_effects, {char = 'O', time = 10, delay = 0, x = sx, y = sy, color = function () love.graphics.setColor(0, 100, 255, 255) end})
	
	danmaku = {x = sx, y = sy, dx = player_last_move.x, dy = player_last_move.y, ex = ex, ey = ey, cd = 3, char = '*', color = function () love.graphics.setColor(0, 100, 255, 255) end}

end
	
function fantasy_seal(sx, sy, range, stat)

	local sx = sx
	local sy = sy
	local range = range
	local mons = {}
	local dam = math.random(player_stats[stat] * 14, player_stats[stat] * 16)
	local d1 = '#'
	local d2 = '*'
	local color = function () love.graphics.setColor(0, 100, 255, 255) end
	
	if stat == 'str' then
		d1 = '()'
		d2 = 'o'
		color = function () love.graphics.setColor(255, 0, 100, 255) end
	end
	
	for i = 1, range do
	
		for xx = sx-i, sx+i do
			--- hit effects
			table.insert(ascii_effects, {char = d1, time = (range + i), delay = i * 2, x = xx, y = sy-i, color = color})
			table.insert(ascii_effects, {char = d1, time = (range + i), delay = i * 2, x = xx, y = sy+i, color = color})
			--- dissipate effects
			table.insert(ascii_effects, {char = d2, time = (range + i), delay = i * 4, x = xx, y = sy-i, color = color})
			table.insert(ascii_effects, {char = d2, time = (range + i), delay = i * 4, x = xx, y = sy+i, color = color})
			--- check for monsters hit
			if map[xx][sy-i]:get_holding() then table.insert(mons, {x=xx, y=sy-i}) end
			if map[xx][sy+i]:get_holding() then table.insert(mons, {x=xx, y=sy+i}) end
		end
		for yy = sy-i+1, sy+i-1 do
			--- hit effects
			table.insert(ascii_effects, {char = d1, time = (range + i), delay = i * 2, x = sx-i, y = yy, color = color})
			table.insert(ascii_effects, {char = d1, time = (range + i), delay = i * 2, x = sx+i, y = yy, color = color})
			--- disssipate effects
			table.insert(ascii_effects, {char = d2, time = (range + i), delay = i * 4, x = sx-i, y = yy, color = color})
			table.insert(ascii_effects, {char = d2, time = (range + i), delay = i * 4, x = sx+i, y = yy, color = color})	
			--- check for monstesr hit
			if map[sx-i][yy]:get_holding() then table.insert(mons, {x=sx-i, y=yy}) end
			if map[sx+i][yy]:get_holding() then table.insert(mons, {x=sx+i, y=yy}) end
		end	
		
	end
	
	if # mons > 0 then
		for i = 1, # mons do			
			map[mons[i].x][mons[i].y]:get_holding():take_dam(dam, 'bomb', 'whut')
		end
	end

end
	
function circle_danmaku(sx, sy, range)

	local sx = sx
	local sy = sy
	local x = sx
	local y = sy
	local dx = 0
	local dy = 0
	local ex = 0
	local ey = 0
	local d = 0
	local air = true
	
	for i = 1, 8 do
	
		if i == 1 then dx = 0 dy = -1 end
		if i == 2 then dx = -1 dy = -1 end
		if i == 3 then dx = -1 dy = 0 end
		if i == 4 then dx = -1 dy = 1 end
		if i == 5 then dx = 0 dy = 1 end
		if i == 6 then dx = 1 dy = 1 end
		if i == 7 then dx = 1 dy = 0 end
		if i == 8 then dx = 1 dy = -1 end
		
		d = 0
		air = true
		x = sx
		y = sy
		
		repeat
		
			x = x + dx
			y = y + dy
			d = d + 1
			
			if map[x][y]:get_block_move() then air = false end
			if d >= range then air = false end
			if map[x][y]:get_holding() then 
				air = false 
				local dam = math.random(player_stats.int * 4, player_stats.int * 5)
				map[x][y]:get_holding():take_dam(dam, 'danmaku', 'whut')
			end
			
			ex = x
			ey = y
		
		until not air
		
		if i == 1 then 
			danmaku = {x = player:get_x(), y = player:get_y(), dx = dx, dy = dy, ex = x, ey = y, cd = 3, char = '*', color = function () love.graphics.setColor(0, 100, 255, 255) end}
		else
			table.insert(danmaku_add, {x = player:get_x(), y = player:get_y(), dx = dx, dy = dy, ex = x, ey = y, cd = 3, char = '*', color = function () love.graphics.setColor(0, 100, 255, 255) end})
		end
		
	end

end