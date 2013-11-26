--- game files
require("map")
require("items")
require("monsters")
require("spells")
require("characters")

map = {}
map_width = 46
map_height = 33
map_special_rooms = {}
map_canvas = love.graphics.newCanvas(800, 600)
map_back_canvas = love.graphics.newCanvas(800, 600)

char_width = 14

player = {}
player_level = 1
player_exp = 0
player_gold = 1110
player_food = {level = 500, cap = 1000, hungry = 300, starving = 100, weak = 25}
player_name = 'Reimu Hakurei'
player_stances = { 'Graze', 'Defensive', 'Normal', 'Offensive', 'Trance' }
player_stance = 3

player_move_cd = 0
player_last_move = {x = 0, y = 0}

player_encumbrance = 0

player_stats = { str = 6,
				 dex = 9,
				 int = 5,
				 con = 7,}
	
player_skills = { fighting = 0, evasion = 0, danmaku = 0, cooking = 0, shinto = 0, stick = 0, longsword = 0, shortblade = 0, axe = 0 }
skills_open = false

feats_open = false
feats_gain_open = false
player_feats = {	{name = 'Stick Proficiency', desc = 'Increases damage done by all stick weapons by 5%', have = false, stick = 1.05},
					{name = 'Long Sword Proficiency', desc = 'Increases damage done by all long sword weapons by 5%', have = false, longsword = 1.05},
					{name = 'Short Blade Proficiency', desc = 'Increases damage done by all short blade weapons by 5%', have = false, shortblade = 1.05},
					{name = 'Shinto Proficiency', desc =  'Increases damage done by all shinto weapons by 5%', have = false, shinto = 1.05},
					{name = 'Axe Proficiency', desc = 'Increases damage done by all axe weapons by 5%', have = false, axe = 1.05},
					{name = 'Athletics', desc = 'Increases speed once and strength and dexterity on levelup', have = false, speed = 1, athletics = 5},
					{name = 'Iron Skin', desc = 'Decreases damage recieved from all sources by 5%', have = false, damred = 0.95},
					{name = 'First Aid', desc = 'Regenerates hit points at a faster rate', have = false, hpregen = 30},
					{name = 'Mana Battery', desc = 'Regenerates mana at a faster rate', have = false, manaregen = 15},
					}
	
player_spells = { }
player_spells_learn = {}
spells_open = false

player_mods = {}

player_inventory = { }
inventory_open = false
inventory_action = false
inventory_to_drop = {}

danmaku_dir = false
danmaku = false
danmaku_add = {}

ascii_effects = {}

shop_window = false
shop_items = { }

help_open = false
help_img = love.graphics.newImage("media/help.png")

look_open = false
look_cursor = { x = 25, y = 25 }

player_equipment = {	head = nil,
						torso = nil,
						legs = nil,
						feet = nil,
						hand = nil,
						}

pickup_many_items = false
pickup_many_items_choice = {}
items_sorted = {}

level = {name = 'Forest', depth = 1}
level_connection = {}
path_to_player = nil
messages = {}

next_turn = false
stair_cd = 0

world_time = 4000
world_see_distance = 8

alphabet = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'}
game_font = love.graphics.newFont("media/coolvetica.ttf", 14)

intro_open = false
player_dead = false

function game:enter()
	
	if not love.filesystem.exists("player.lua") then
		intro_open = true
	end
	
	player = Creature:new(game_characters[1].stats)
	starting_inventory()
	map_hakurei_shrine('up')
	setup_character()
	map_back_canvas_draw()
	path_to_player = dijkstra_map(player:get_x(), player:get_y())
	player_fov()

end

function game:draw()

	love.graphics.setFont(game_font)

	map_draw()
	player_hud()
	player_message()
	
	if inventory_open then draw_inventory() end
	if pickup_many_items then draw_many_item_pickup() end
	if spells_open then draw_spells() end
	if shop_window then draw_shop() end
	if skills_open then draw_skills() end
	if feats_open then draw_feats() end
	if feats_gain_open then draw_feats_gain() end
	if help_open then draw_help() end
	if look_open then draw_look() end
	if intro_open then draw_intro() end
	
	--- player dead drawing
	if player_dead then
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle('fill', ascii_draw_point(player:get_x()), ascii_draw_point(player:get_y()), char_width, char_width)
		love.graphics.setColor(255, 0, 0, 255)
		love.graphics.print('@', ascii_draw_point(player:get_x()), ascii_draw_point(player:get_y()))
		love.graphics.setColor(255, 255, 255, 255)
	end

	--- ascii effects draw
	if # ascii_effects > 0 then
		for i = 1, # ascii_effects do
			if ascii_effects[i].delay < 1 then
				ascii_effects[i].color()
				love.graphics.print(ascii_effects[i].char, ascii_draw_point(ascii_effects[i].x), ascii_draw_point(ascii_effects[i].y))
				love.graphics.setColor(255, 255, 255, 255)
			end
		end
	end
	
	--- danmaku draw
	if danmaku then
		danmaku.color()
		love.graphics.print('*', ascii_draw_point(danmaku.x), ascii_draw_point(danmaku.y))
		love.graphics.setColor(255, 255, 255, 255)
	end
	
	--- debug coordinate view
	love.graphics.setCaption("(" .. player:get_x() .. "," .. player:get_y() .. ")" .. "   FPS:" .. love.timer.getFPS())
	
end

function game:keypressed(key)

	if player:get_turn_cd() <= 1 and not danmaku and # ascii_effects == 0 then
		if not inventory_open and not player_dead and not intro_open and not look_open and not help_open and not feats_gain_open and not pickup_many_items and not spells_open and not shop_window and not danmaku_dir and not skills_open and not feats_open then
			
			--- keypad movement
			if key == 'kp8' then player:move(0, -1) next_turn = true end
			if key == 'kp2' then player:move(0, 1) next_turn = true end
			if key == 'kp4' then player:move(-1, 0) next_turn = true end
			if key == 'kp6' then player:move(1, 0) next_turn = true end
			if key == 'kp7' then player:move(-1, -1) next_turn = true end
			if key == 'kp9' then player:move(1, -1) next_turn = true end
			if key == 'kp1' then player:move(-1, 1) next_turn = true end
			if key == 'kp3' then player:move(1, 1) next_turn = true end
			if key == 'kp5' then next_turn = true end
			--- vi keys movement
			if key == 'k' then player:move(0, -1) next_turn = true end
			if key == 'j' then player:move(0, 1) next_turn = true end
			if key == 'h' then player:move(-1, 0) next_turn = true end
			if key == 'l' then player:move(1, 0) next_turn = true end
			if key == 'y' then player:move(-1, -1) next_turn = true end
			if key == 'u' then player:move(1, -1) next_turn = true end
			if key == 'b' then player:move(-1, 1) next_turn = true end
			if key == 'n' then player:move(1, 1) next_turn = true end
			if key == '.' then next_turn = true end
			--- arrow key movement (for whatever retards actually use these)
			if key == 'up' then player:move(0, -1) next_turn = true end
			if key == 'down' then player:move(0, 1) next_turn = true end
			if key == 'left' then player:move(-1, 0) next_turn = true end
			if key == 'right' then player:move(1, 0) next_turn = true end
			
			if key == '-' or key == 'kp-' then player_stance = player_stance - 1 end
			if key == '+' or key == 'kp+' then player_stance = player_stance + 1 end
			
			if player_stance > 5 then player_stance = 5 end
			if player_stance < 1 then player_stance = 1 end
			
			if key == ' ' then player_exp = player_exp + 1000000 player:levelup() end
			
			if level.name ~= 'Overworld' then
				if key == 'g' then pickup_item() next_turn = true end
				if key == 'i' then inventory_open = true inventory_action = 'look' sort_player_inventory() end
				if key == 'd' then inventory_open = true inventory_action = 'drop' inventory_to_drop = {} sort_player_inventory() end
				if key == 'w' then inventory_open = true inventory_action = 'wield' sort_player_inventory() end
				if key == 'p' then inventory_open = true inventory_action = 'wear' sort_player_inventory() end
				if key == 't' then inventory_open = true inventory_action = 'remove' sort_player_inventory() end
				if key == 'q' then inventory_open = true inventory_action = 'quaff' sort_player_inventory() end
				if key == 'e' then inventory_open = true inventory_action = 'eat' sort_player_inventory() end
				if key == 'r' then inventory_open = true inventory_action = 'read' sort_player_inventory() end
				if key == 'a' then inventory_open = true inventory_action = 'apply' sort_player_inventory() end
				
				if key == 'c' then spells_open = true end
				if key == 'v' then map_use_tile() end	
				
				if key == 'x' then skills_open = true end
				if key == 'z' then feats_open = true end

				if key == 'f' then danmaku_dir = true message_add("Fire danmaku in which direction? ESC to cancel.") end
			end
			
		elseif inventory_open and inventory_action == 'look' then
			if key then inventory_open = false end
		elseif inventory_open and inventory_action == 'drop' then
			drop_item_key(key)
		elseif inventory_open and inventory_action == 'wield' then
			wield_key(key)
		elseif inventory_open and inventory_action == 'wear' then
			wear_key(key)
		elseif inventory_open and inventory_action == 'remove' then
			remove_key(key)
		elseif inventory_open and inventory_action == 'quaff' then
			quaff_key(key)
		elseif inventory_open and inventory_action == 'cook' then
			cook_key(key)
		elseif inventory_open and inventory_action == 'eat' then	
			eat_key(key)
		elseif inventory_open and inventory_action == 'sell' then	
			sell_key(key)
		elseif inventory_open and inventory_action == 'read' then	
			read_key(key)
		elseif inventory_open and inventory_action == 'apply' then	
			apply_key(key)
		
		elseif pickup_many_items then
			pickup_many_items_key(key)
		elseif spells_open then
			spells_key(key)
		elseif shop_window then
			shop_key(key)
		elseif skills_open then
			if key then skills_open = false end
		elseif feats_open then
			if key then feats_open = false end
		elseif feats_gain_open then	
			feats_gain_key(key)
		elseif help_open then
			if key then help_open = false end
		elseif intro_open then
			if key then intro_open = false end
		elseif player_dead then
			if key == 'return' or key == 'escape' or key == 'kpenter' then love.event.push('quit') end
			
		elseif look_open then
			--- keypad movement
			if key == 'kp8' then look_cursor.y = look_cursor.y - 1 end
			if key == 'kp2' then look_cursor.y = look_cursor.y + 1 end
			if key == 'kp4' then look_cursor.x = look_cursor.x - 1 end
			if key == 'kp6' then look_cursor.x = look_cursor.x + 1 end
			if key == 'kp7' then look_cursor.y = look_cursor.y - 1 look_cursor.x = look_cursor.x - 1 end
			if key == 'kp9' then look_cursor.y = look_cursor.y - 1 look_cursor.x = look_cursor.x + 1 end
			if key == 'kp1' then look_cursor.y = look_cursor.y + 1 look_cursor.x = look_cursor.x - 1 end
			if key == 'kp3' then look_cursor.y = look_cursor.y + 1 look_cursor.x = look_cursor.x + 1 end
			--- vi keys
			if key == 'k' then look_cursor.y = look_cursor.y - 1 end
			if key == 'j' then look_cursor.y = look_cursor.y + 1 end
			if key == 'h' then look_cursor.x = look_cursor.x - 1 end
			if key == 'l' then look_cursor.x = look_cursor.x + 1 end
			if key == 'y' then look_cursor.y = look_cursor.y - 1 look_cursor.x = look_cursor.x - 1 end
			if key == 'u' then look_cursor.y = look_cursor.y - 1 look_cursor.x = look_cursor.x + 1 end
			if key == 'b' then look_cursor.y = look_cursor.y + 1 look_cursor.x = look_cursor.x - 1 end
			if key == 'n' then look_cursor.y = look_cursor.y + 1 look_cursor.x = look_cursor.x + 1 end
			--- movement keys
			if key == 'up' then look_cursor.y = look_cursor.y - 1 end
			if key == 'down' then look_cursor.y = look_cursor.y + 1 end
			if key == 'left' then look_cursor.x = look_cursor.x - 1 end
			if key == 'right' then look_cursor.x = look_cursor.x + 1 end
			--- exit key
			if key == 'return' or key == 'escape' or key == 'kpenter' then
				look_open = false
			end
			--- check to make sure cursor is within map
			if look_cursor.x < 1 then look_cursor.x = 1 end
			if look_cursor.y < 1 then look_cursor.y = 1 end
			if look_cursor.x > map_width then look_cursor.x = map_width end
			if look_cursor.y > map_height then look_cursor.y = map_height end
			
		elseif danmaku_dir then
			if key == 'escape' or key == 'return' or key == 'kpenter' then danmaku_dir = false message_add("Never mind.") end
			
			if key == 'kp8' then danmaku_fire(0, -1) danmaku_dir = false next_turn = true end
			if key == 'kp2' then danmaku_fire(0, 1) danmaku_dir = false next_turn = true end
			if key == 'kp4' then danmaku_fire(-1, 0) danmaku_dir = false next_turn = true end
			if key == 'kp6' then danmaku_fire(1, 0) danmaku_dir = false next_turn = true end
			if key == 'kp7' then danmaku_fire(-1, -1) danmaku_dir = false next_turn = true end
			if key == 'kp9' then danmaku_fire(1, -1) danmaku_dir = false next_turn = true end
			if key == 'kp1' then danmaku_fire(-1, 1) danmaku_dir = false next_turn = true end
			if key == 'kp3' then danmaku_fire(1, 1) danmaku_dir = false next_turn = true end
			if key == 'kp3' then danmaku_fire(1, 1) danmaku_dir = false next_turn = true end
			
		end		
	end
	
end

function game:update(dt)

	if not danmaku and # ascii_effects == 0 then turn_machine() end
	stair_cd = stair_cd - 1
	player_move_cd = player_move_cd - 1
	
	if not inventory_open and not player_dead and not intro_open and not feats_open and not feats_gain_open and not pickup_many_items and not spells_open and not shop_window and not danmaku_dir and not skills_open then
		if player:get_turn_cd() <= 1 and player_move_cd < 1 and stair_cd <= 1 and not danmaku and # ascii_effects == 0 then
			--- up and down stairs in levels
			if (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and love.keyboard.isDown('.') and map[player:get_x()][player:get_y()]:get_name() == 'DStairs' then stair_machine('down') end
			if (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and love.keyboard.isDown(',') and map[player:get_x()][player:get_y()]:get_name() == 'UStairs'  then stair_machine('up') end
			--- down for the overworld
			if (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and love.keyboard.isDown('.') and level.name == 'Overworld' then overworld_down() end
			--- open the help file
			if (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and love.keyboard.isDown('/') then help_open = true end
			--- save the game
			if (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and love.keyboard.isDown('s') then
				love.graphics.setCaption('SAVING....')
				save_map_check()
				save_player()
				love.graphics.setCaption('TouhouLike')
			end
			--- look key
			if (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and love.keyboard.isDown(';') then 
				look_open = true 
				look_cursor.x = player:get_x()
				look_cursor.y = player:get_y()
			end
		end
	end
	
	--- check for encumbrance
	if player_held_weight() < player_stats.str * 10 then
		player_encumbrance = 0
	elseif player_held_weight() >= player_stats.str * 10 then
		player_encumbrance = 1
	elseif player_held_weight() >= player_stats.str * 12 then
		player_encumbrance = 2
	end
	
	--- ascii effects update
	if # ascii_effects > 0 then
		for i = 1, # ascii_effects do
			if i > # ascii_effects then break end
			
			if ascii_effects[i].delay < 1 then
				ascii_effects[i].time = ascii_effects[i].time - 1
			else
				ascii_effects[i].delay = ascii_effects[i].delay - 1
			end
			
			if ascii_effects[i].time < 1 then
				table.remove(ascii_effects, i)
				i = i - 1
			end
			
		end
	end
	
	--- danmaku update
	if danmaku then
		danmaku.cd = danmaku.cd - 1
		if danmaku.cd < 1 then
			danmaku.cd = 3
			danmaku.x = danmaku.x + danmaku.dx
			danmaku.y = danmaku.y + danmaku.dy
			
			--- check for danmaku end
			if danmaku.x == danmaku.ex and danmaku.y == danmaku.ey then
				danmaku = false
				
				--- danmaku additions
				if # danmaku_add > 0 then
					danmaku = danmaku_add[1]
					table.remove(danmaku_add, 1)
				end
				
			end
		end
	end

end

function overworld_down()

	for i = 1, # overworld_levels do
		if player:get_x() == overworld_levels[i].x and player:get_y() == overworld_levels[i].y then
			save_map_check()
			save_player()
			overworld_levels[i].func('down')
			stair_cd = 3
			map_back_canvas_draw()
			player_fov()
		end
	end

end

function aoe_danmaku_dam(x, y, range, delay)

	for xx = x-range, x+range do
		for yy = y-range, y+range do
			
			table.insert(ascii_effects, {char = '#', time = 5, delay = delay, x = xx, y = yy, color = function () love.graphics.setColor(0, 100, 255, 255) end})
			if xx > 1 and xx < map_width and yy > 1 and yy < map_height then
				if map[xx][yy]:get_holding() then
					local dam = math.random(player_stats.int * 2, player_stats.int * 3)
					map[xx][yy]:get_holding():take_dam(dam, 'danmaku', 'whut')
				end
			end
			
		end
	end

end

function sort_player_inventory()

	player_inventory = sort_items_categories(player_inventory)

end

function danmaku_fire(dx, dy)

	local air = true
	local x = player:get_x()
	local y = player:get_y()
	local d = 0
	local bullets = 1
	local mana_cost = 0
	
	if player_stance == 1 or player_stance == 2 then
		bullets = 1
	elseif player_stance == 3 then
		bullets = 1
	elseif player_stance == 4 then
		bullets = 2
	elseif player_stance == 5 then
		bullets = 2
	end
	
	--- bullet num modifiers
	bullets = bullets + player_mod_get('bullet')
	--- weapons that add bullets
	if player_equipment.hand then
		bullets = bullets + player_equipment.hand:get_bullet()
	end
	
	--- mana cost
	mana_cost = bullets * 5
	if mana_cost > player:get_mana_cur() then
		repeat
			bullets = bullets - 1
			mana_cost = bullets * 5
		until mana_cost <= player:get_mana_cur()
	end
	--- we don't have enough mana to fire any bullets
	if bullets < 1 then 
		message_add("You don't have enough mana to fire any danmaku!")
		return 
	end
	
	message_add("You fired danmaku!")
	player:lose_mana(mana_cost)
	
	for i = 1, bullets do
		air = true
		x = player:get_x()
		y = player:get_y()
		d = 0
		
		repeat
		
			x = x + dx
			y = y + dy
			d = d + 1
			
			if map[x][y]:get_block_move() then air = false end
			if map[x][y]:get_holding() then 
				air = false 
				local dam = math.floor(math.random(player_stats.int * 4, player_stats.int * 5) * ((((player_skills.danmaku + 1) * 2) * 0.01) + 1))
				map[x][y]:get_holding():take_dam(dam, 'danmaku', 'whut')			
				player_skills.danmaku = player_skills.danmaku + 0.001
			end
			
			if d == 8 then
				air = false
			end
			
			if not air then
				--- danmaku aoe modifier
				if player_mod_get('danmaku_explosive') > 0 then
					aoe_danmaku_dam(x, y, player_mod_get('danmaku_explosive'), d * 3 * i)
				end
			end
			
			ex = x
			ey = y
		
		until not air
	end
		
	danmaku = {x = player:get_x(), y = player:get_y(), dx = dx, dy = dy, ex = x, ey = y, cd = 3, char = '*', color = function () love.graphics.setColor(0, 100, 255, 255) end}
	for i = 1, bullets + player_mod_get('bullet') - 1 do
		table.insert(danmaku_add, {x = player:get_x(), y = player:get_y(), dx = dx, dy = dy, ex = x, ey = y, cd = 3, char = '*', color = function () love.graphics.setColor(0, 100, 255, 255) end})
	end

end

function enemy_danmaku_fire(sx, sy, dx, dy, bullets, dam, name)

	message_add("The " .. name .. " fired danmaku!")
	
	local air = true
	local x = sx
	local y = sy
	local d = 0
	local ex = 0
	local ey = 0
	
	for i = 1, bullets do
		air = true
		x = sx
		y = sy
		d = 0
	
		repeat
		
			x = x + dx
			y = y + dy
			d = d + 1
			
			if map[x][y]:get_block_move() then air = false end
			if x == player:get_x() and y == player:get_y() then
				air = false
				player:take_dam(dam, 'danmaku', name)
			end
			
			if d == 8 then
				air = false
			end
			
			ex = x
			ey = y
		
		until not air
	
	end
	
	danmaku = {x = sx, y = sy, dx = dx, dy = dy, ex = ex, ey = ey, cd = 3, char = '*', color = function () love.graphics.setColor(0, 255, 100, 255) end}
	for i = 1, bullets - 1 do
		table.insert(danmaku_add, {x = sx, y = sy, dx = dx, dy = dy, ex = ex, ey = ey, cd = 3, char = '*', color = function () love.graphics.setColor(0, 255, 100, 255) end})
	end

end

function feats_gain_key(key)

	for i = 1, # player_feats do
		if alphabet[i] == key and not player_feats[i].have then
			player_feats[i].have = true
			message_add("You gain " .. player_feats[i].name)
			feats_gain_open = false
		end
	end

end

function apply_key(key)

	for i = 1, # player_inventory do
		if key == alphabet[i] and player_inventory[i] and player_inventory[i].item:get_apply() then			
			player_inventory[i].item:get_afunc()()
			message_add(player_inventory[i].item:get_message())
			inventory_open = false
			next_turn = true
			
		elseif key == alphabet[i] and player_inventory[i] and not player_inventory[i].item:get_apply() then
			message_add("How could you possibly apply that?")
			
		elseif key == alphabet[i] and player_inventory[i] and player_inventory[i].item:get_potion() then
			player_inventory[i].quantity = player_inventory[i].quantity  - 1
			message("You empty the " .. player_inventory[i].item:get_name() .. ".")
			add_item_to_inventory(Item:new({name = 'Empty Bottle', char = '!', prob = 33}))
			if player_inventory[i].quantity < 1 then table.remove(player_inventory, i) end
			inventory_open = false
			next_turn = true
			
		end
	end

	if key == 'escape' or key == 'return' or key == 'kpenter' then
		inventory_open = false
		message_add("Never mind")
	end

end

function read_key(key)

	for i = 1, # player_inventory do
		if key == alphabet[i] and player_inventory[i] and player_inventory[i].item:get_read() then
			player_inventory[i].item:get_affect()()
			message_add(player_inventory[i].item:get_message())
			
			local known = false
			for k = 1, # known_scrolls do
				if known_scrolls[k] == player_inventory[i].item:get_name() then
					known = true
				end
			end
			if not known then table.insert(known_scrolls, player_inventory[i].item:get_name()) end
				
			player_inventory[i].quantity = player_inventory[i].quantity - 1
			inventory_open = false
			next_turn = true
			if player_inventory[i].quantity < 1 then
				table.remove(player_inventory, i)
			end
		elseif key == alphabet[i] and player_inventory[i] and not player_inventory[i].item:get_read() then
			message_add("What\'s there to read?.")
		end
	end

	if key == 'escape' or key == 'return' or key == 'kpenter' then
		inventory_open = false
		message_add("Never mind")
	end

end

function sell_key(key)

	for i = 1, # player_inventory do
		if key == alphabet[i] then
		
			player_gold = player_gold + 5
			message_add("You sold your " .. player_inventory[i].item:get_name() .. " for 5 gold.")
		
			player_inventory[i].quantity = player_inventory[i].quantity - 1
			if player_inventory[i].quantity < 1 then
				table.remove(player_inventory, i)
			end
		
		end
	end

	if key == 'escape' or key == 'return' or key == 'kpenter' then
		message_add("Never mind")
		inventory_open = false
	end

end

function shop_key(key)

	for i = 1, # shop_items do
		if key == alphabet[i] then
			if shop_items[i].cost <= player_gold then
				message_add("You bought the " .. shop_items[i].name .. " for " .. shop_items[i].cost .. " gold.")
				add_item_to_inventory(shop_items[i].item)
				player_gold = player_gold - shop_items[i].cost
			else
				message_add("You don't have enough gold to pay for that!")
			end
		end
	end

	if key == 'escape' or key == 'return' or key == 'kpenter' then
		message_add("Never mind")
		shop_window = false
	end

end

function spells_key(key)

	for i = 1, # player_spells do
		if key == alphabet[i] then
			if player:get_mana_cur() >= player_spells[i].mp_cost then
				player_spells[i].func()
				player:lose_mana(player_spells[i].mp_cost)
				message_add("You cast " .. player_spells[i].name .. ".")
				spells_open = false
				next_turn = true
			else
				message_add("You don't have enough MP to cast that!")
				spells_open = false
			end
		end
	end

	if key == 'escape' or key == 'return' or key == 'kpenter' then
		message_add("Never mind")
		spells_open = false
	end

end

function eat_key(key)

	for i = 1, # player_inventory do
		if key == alphabet[i] and player_inventory[i] and player_inventory[i].item:get_edible() then
		
			player_food.level = player_food.level + player_inventory[i].item:get_nutrition()
			
			local text = ""
			text = text .. "You eat the " .. player_inventory[i].item:get_name() .. "."
			if player_food.level < 300 then text = text .. "  You still need more food."
			elseif player_food.level < 500 then text = text .. "  You could eat much more." 
			elseif player_food.level < 750 then text = text .. "  That really hit the spot."
			elseif player_food.level < 850 then text = text .. "  You feel bloated." 
			elseif player_food.level < 1000 then text = text .. "  You have a hard time swallowing." end
			if player_inventory[i].item:get_corpse() then text = text .. "  That " .. player_inventory[i].item:get_corpse() .. " was disgusting." end
			message_add(text)
			
			inventory_open = false
			next_turn = true
		
			player_inventory[i].quantity = player_inventory[i].quantity - 1
			if player_inventory[i].quantity < 1 then
				table.remove(player_inventory, i)
			end
		
		end
	end

	if key == 'escape' or key == 'return' or key == 'kpenter' then
		inventory_open = false
		message_add("Never mind.")
	end

end

function cook_key(key)

	for i = 1, # player_inventory do
		if key == alphabet[i] and player_inventory[i] and player_inventory[i].item:get_cook() then
					
			add_item_to_inventory(cook_food(player_inventory[i].item))
			
			player_inventory[i].quantity = player_inventory[i].quantity - 1
			if player_inventory[i].quantity < 1 then
				table.remove(player_inventory, i)
			end
			
			inventory_open = false
			next_turn = true
			
		end
	end

	if key == 'escape' or key == 'return' or key == 'kpenter' then
		inventory_open = false
		message_add("Never mind.")
	end

end

function quaff_key(key)

	for i = 1, # player_inventory do
		if key == alphabet[i] and player_inventory[i] and player_inventory[i].item:get_quaff() then
			player_inventory[i].item:get_affect()()
			message_add(player_inventory[i].item:get_message())
			
			local known = false
			for k = 1, # known_potions do
				if known_potions[k] == player_inventory[i].item:get_name() then
					known = true
				end
			end
			if not known then table.insert(known_potions, player_inventory[i].item:get_name()) end
				
			player_inventory[i].quantity = player_inventory[i].quantity - 1
			inventory_open = false
			next_turn = true
			if player_inventory[i].quantity < 1 then
				table.remove(player_inventory, i)
			end
		elseif key == alphabet[i] and player_inventory[i] and not player_inventory[i].item:get_quaff() then
			message_add("You couldn't possibly quaff that even if you wanted to.")
		end
	end

	if key == 'escape' or key == 'return' or key == 'kpenter' then
		inventory_open = false
		message_add("Never mind")
	end

end

function remove_key(key)

	local slot = false

	if key == 'a' then
		slot = 'head'
	elseif key == 'b' then
		slot = 'torso'
	elseif key == 'c' then
		slot = 'legs' 
	elseif key == 'd' then
		slot = 'feet'
	elseif key == 'e' then
		slot = 'hand'
	end
	
	if slot then
		if player_equipment[slot]	then
			message_add("You remove your " .. player_equipment[slot]:get_name() .. ".")
			add_item_to_inventory(player_equipment[slot])
			player_equipment[slot] = false
		else
			message_add("You weren't wearing anything there.")
		end
		inventory_open = false
	end
	
	if key == 'escape' then
		inventory_open = false
		message_add("Never mind.")
	end

end

function wear_key(key)

	if key then
		for i = 1, # alphabet do
			if key == alphabet[i] and player_inventory[i] then
				if player_inventory[i].item:get_slot() then
					local slot = player_inventory[i].item:get_slot()
					
					if slot == 'torso' then
						if not player_equipment.torso then
							player_equipment.torso = player_inventory[i].item
							player_inventory[i].quantity = player_inventory[i].quantity - 1
							message_add("You put on your " .. player_equipment.torso:get_name() .. ".")
						else
							message_add("You are already wearing something over your body.")
						end
					elseif slot == 'head' then
						if not player_equipment.head then
							player_equipment.head = player_inventory[i].item
							player_inventory[i].quantity = player_inventory[i].quantity - 1
							message_add("You put on your " .. player_equipment.head:get_name() .. ".")
						else
							message_add("You are already wearing something on your head.")
						end
					elseif slot == 'legs' then
						if not player_equipment.legs then
							player_equipment.legs = player_inventory[i].item
							player_inventory[i].quantity = player_inventory[i].quantity - 1
							message_add("You put on your " .. player_equipment.legs:get_name() .. ".")
						else
							message_add("You are already wearing something around your legs.")
						end
					elseif slot == 'feet' then
						if not player_equipment.feet then
							player_equipment.feet = player_inventory[i].item
							player_inventory[i].quantity = player_inventory[i].quantity - 1
							message_add("You put on your " .. player_equipment.feet:get_name() .. ".")
						else
							message_add("You are already wearing something on your feet.")
						end
					end
					
					if player_inventory[i].quantity < 1 then
						table.remove(player_inventory, i)
					end
					inventory_open = false
					
				end
			end
		end
	end
	
	if key == 'escape' then
		inventory_open = false
		message_add("Never mind")
	end

end

function wield_key(key)

	if key then
		for i = 1, # alphabet do
			if key == alphabet[i] and player_inventory[i] then
				local message = ""
				if player_equipment.hand then
					message = message .. "You put your " .. player_equipment.hand:get_name() .. " away.  "
					add_item_to_inventory(player_equipment.hand)
				end
				player_equipment.hand = player_inventory[i].item
				message = message .. "You are now wielding a " .. player_equipment.hand:get_name() .. "."
				message_add(message)
				player_inventory[i].quantity = player_inventory[i].quantity - 1
				if player_inventory[i].quantity < 1 then
					table.remove(player_inventory, i)
				end
				inventory_open = false
			end		
		end
	end
	
	if key == 'return' or key == 'kpenter' then
		local message = ""
		if player_equipment.hand then
			message = message .. "You put your " .. player_equipment.hand:get_name() .. " away.  "
			add_item_to_inventory(player_equipment.hand)
		end
		message = message .. "You are now empty handed."
		message_add(message)
		player_equipment.hand = false
		inventory_open = false
	end
	
	if key == 'escape' then
		inventory_open = false
		message_add("Never mind")
	end

end

function pickup_many_items_key(key)

	local toomany = false

	if key  == 'return' or key == 'kpenter' then	
		--- add items to player inventory
		for i = 1, # alphabet do
			if pickup_many_items_choice[alphabet[i]] and items_sorted[i] then
				if # player_inventory < # alphabet then
					for k = 1, items_sorted[i].quantity do
						add_item_to_inventory(items_sorted[i].item)
						items_sorted[i].quantity = items_sorted[i].quantity - 1
					end
				else
					toomany = true
				end
			end
		end
		--- remove items that were picked up, leave others
		for i = 1, # items_sorted do
			if i > # items_sorted then break end
			if items_sorted[i].quantity < 1 then
				table.remove(items_sorted, i)
				i = i - 1
			end
		end
		--- find out which items were left on the ground
		local map_items = {}
		for i = 1, # items_sorted do
			for k = 1, items_sorted[i].quantity do
				table.insert(map_items, items_sorted[i].item)
			end
		end
		--- add the items left over back onto to the map
		if # map_items > 0 then
			map[player:get_x()][player:get_y()]:set_items(map_items)
		else
			map[player:get_x()][player:get_y()]:set_items(false)
		end
		
		pickup_many_items = false
		pickup_many_items_choice = {}
		items_sorted = {}
		
		if toomany then
			message_add("You weren't able to fit everything into your knapsack.")
		end
		
	else
		--- select which items will be picked up or not
		for i = 1, # alphabet do
			if key == alphabet[i] then
				if not pickup_many_items_choice[alphabet[i]] then
					pickup_many_items_choice[alphabet[i]] = true
				else
					pickup_many_items_choice[alphabet[i]] = false
				end
			end
		end
	end
	
end

function drop_item_key(key)

	if key == 'return' or key == 'kpenter' then
		drop_items()
		inventory_open = false
		inventory_to_drop = {}
	else
		for i = 1, # alphabet do
			if key == alphabet[i] then
				if not inventory_to_drop[alphabet[i]] then 
					inventory_to_drop[alphabet[i]] = true
				else
					inventory_to_drop[alphabet[i]] = false
				end
			end
		end
	end
			
end

function drop_items()
	
	--- get all items to drop
	local items = {}
	for i = 1, # player_inventory do
		if inventory_to_drop[alphabet[i]] and player_inventory[i] then
			local go_to = player_inventory[i].quantity
			for k = 1, go_to do
				table.insert(items, player_inventory[i].item)
				player_inventory[i].quantity = player_inventory[i].quantity - 1			
			end
			inventory_to_drop[alphabet[i]] = false
		end
	end
	
	--- remove items from players inventory
	local i = 1
	repeat
		if player_inventory[i] and player_inventory[i].quantity < 1 then
			table.remove(player_inventory, i)
			i = i - 1
		end
		i = i + 1
	until i > # player_inventory
	
	--- get items already on the map tile
	local world_items = map[player:get_x()][player:get_y()]:get_items()
	if world_items then
		for i = 1, # world_items do
			table.insert(items, world_items[i])
		end
	end
	
	--- now add all items onto the map tile together
	if # items > 0 then
		map[player:get_x()][player:get_y()]:set_items(items)
	else
		map[player:get_x()][player:get_y()]:set_items(false)
	end

end

function pickup_item()

	local pickuped = true
	if map[player:get_x()][player:get_y()]:get_items() then
	
		many_items_sorted(map[player:get_x()][player:get_y()]:get_items())
		if # map[player:get_x()][player:get_y()]:get_items() == 1 then
			pickuped = add_item_to_inventory(map[player:get_x()][player:get_y()]:get_items()[1])
			if pickuped then
				message_add('You picked up the ' .. map[player:get_x()][player:get_y()]:get_items()[1]:get_pname() .. '.')
				map[player:get_x()][player:get_y()]:set_items(nil)
			end
		else
			pickup_many_items = true
			pickup_many_items_choice = {}			
		end	
		
	end
	return pickuped

end

function add_item_to_inventory(item)

	local pickuped = false

	if item:get_gold() then
		player_gold = player_gold + item:get_gold()
		pickuped = true
		return pickuped
	end

	if # player_inventory == 0 then
		table.insert(player_inventory, {item = item, quantity = 1})
		pickuped = true
	else
		local similar = false
		for i = 1, # player_inventory do
			if player_inventory[i].item:get_name() == item:get_name() then
				player_inventory[i].quantity = player_inventory[i].quantity + 1
				pickuped = true
				similar = true
			end
		end
		if not similar then
			if # player_inventory < # alphabet then
				table.insert(player_inventory, {item = item, quantity = 1})
				pickuped = true
			else
				message_add("You can't fit anything else into your knapsack.")
				pickuped = false
			end
		end
	end
	
	return pickuped
				
end

function add_modifier(mod)

	if # player_mods == 0 then
		table.insert(player_mods, mod)
	else
		local similar = false
		for i = 1, # player_mods do			
			if player_mods[i].name == mod.name then
				player_mods[i].turn = mod.turn
				similar = true
			end
		end
		if not similar then
			table.insert(player_mods, mod)
		end
	end		

end

function turn_machine()

	if next_turn and not player_dead then
		take_turns()	
		world_time_machine()	
		mon_gen_machine()
		if player:get_turn_cd() <= 1 then		
			player:levelup()
			next_turn = false
		end
	end

end

function world_time_machine()

	
	
end

function take_turns()

	local mons_moved = {}

	for x = 1, map_width do
		for y = 1, map_height do
		
			if map[x][y]:get_holding() and map[x][y]:get_holding() ~= player then
			
				local move = true
				for i = 1, # mons_moved do
					if mons_moved[i] == map[x][y]:get_holding() then
						move = false
					end
				end
				
				if move then 
				
					table.insert(mons_moved, map[x][y]:get_holding())
					map[x][y]:get_holding():ai_take_turn()
					if player_dead then return end
				
				end
							
				
			end
			
		end
	end
	
	player:ai_take_turn()
	player:set_turn_cd(0)

end

function message_add(msg)

	table.insert(messages, 1, msg)
	if # messages > 25 then
		table.remove(messages, # messages)
	end

end

function cook_food(food)

	local dice = math.random(1, 100)
	local good = false
	local item = false
	local gain = 0
	
	if dice <= player_skills.cooking ^ 2 then
		good = true
	end
	
	if good then
	
		for i = 1, # game_items do
			if game_items[i].name == 'Cooked ' .. food:get_name() then
				item = Item:new(game_items[i])
				gain = 0.15
				message_add("You successfully cooked your " .. food:get_name() .. ".")
			end
		end
		if not item then
			message_add("Your " .. food:get_name() .. " was destroyed.")
		end
		
	else
	
		for i = 1, # game_items do
			if game_items[i].name == 'Ruined ' .. food:get_name() then
				item = Item:new(game_items[i])
				gain = 0.025
				message_add("You ruined your " .. food:get_name() .. ".")
			end
		end
		if not item then
			message_add("Your " .. food:get_name() .. " was destroyed.")
		end
		
	end
	
	player_skills.cooking = player_skills.cooking + gain
	
	return item

end

function save_player()

	local text = ""
	--- stats
	text = text .. "player_stats = { str = " .. player_stats.str .. ", dex = " .. player_stats.dex .. ", int = " .. player_stats.int .. ", con = " .. player_stats.con .."}\n"
	--- skills
	text = text .. "player_skills = {  "
	for k, v in pairs(player_skills) do
		text = text .. k .. " = " .. v .. ", "
	end
	text = text .. "  } \n"
	--- feats
	text = text .. "player_feats_load = { "
	for i = 1, # player_feats do
		if player_feats[i].have then
			text = text .. "\'" .. player_feats[i].name .. "\', "
		end
	end
	text = text .. "} \n"
	--- food
	text = text .. "player_food = {  "
	for k, v in pairs(player_food) do
		text = text .. k .. " = " .. v .. ", "
	end
	text = text .. "  } \n"
	--- level
	text = text .. "player_level = " .. player_level .. "\n"
	--- name
	text = text .. "player_name = \'" .. player_name .. "\'\n"
	--- spells
	text = text .. "player_spells = { " 
	for i = 1, # player_spells do
		text = text .. save_spell(player_spells[i].name)
	end
	text = text .. "  }\n"
	--- equipment
	text = text .. "player_equipment = {  "
	text = text .. "head = " .. save_item(player_equipment.head)
	text = text .. "torso = " .. save_item(player_equipment.torso)
	text = text .. "legs = " .. save_item(player_equipment.legs)
	text = text .. "feet = " .. save_item(player_equipment.feet)
	text = text .. "hand = " .. save_item(player_equipment.hand)
	text = text .. "  }\n"
	--- inventory
	text = text .. "player_inventory = {  "
	for i = 1, # player_inventory do
		text = text .. "{item = " .. save_item(player_inventory[i].item)
		text = text .. "quantity = " .. player_inventory[i].quantity .. "}, "
	end
	text = text .. "}\n"
	--- known potions
	text = text .. "known_potions = {  "
	for k, v in pairs(known_potions) do
		text = text .. "\'" .. v .. "\', "
	end
	text = text .. "}\n"
	--- known scrolls
	text = text .. "known_scrolls = {  "
	for k, v in pairs(known_scrolls) do
		text = text .. "\'" .. v .. "\', "
	end
	text = text .. "}\n"
	--- unique dead
	text = text .. "unique_dead = {  "
	for k, v in pairs(unique_dead) do
		text = text .. "\'" .. v .. "\', "
	end
	text = text .. "}\n"
	--- exp
	text = text .. "player_exp = " .. player_exp .. "\n"
	--- gold
	text = text .. "player_gold = " .. player_gold .. "\n"
	--- hp and mana levels
	text = text .. "player_hp_mana = { hp_max = " .. player:get_hp_max() .. ", "
	text = text .. "hp_cur = " .. player:get_hp_cur() .. ", "
	text = text .. "mana_max = " .. player:get_mana_max() .. ", "
	text = text .. "mana_cur = " .. player:get_mana_cur() .. ", }\n"
	--- dungeon level
	text = text .. "level = { name = \'" .. level.name .. "\', "
	text = text .. "depth = " .. level.depth .. ", }\n"
	--- x and y coords
	text = text .. "player_coords = { x = " .. player:get_x() .. ", "
	text = text .. "y = " .. player:get_y() .. ", }\n"
	
	love.filesystem.write("player.lua", text)
	
end

function load_player()

	if love.filesystem.exists("player.lua") then
		local chunk = love.filesystem.load("player.lua")
		chunk()
	end
	
end

function load_map()

	if love.filesystem.exists(level.name .. "_" .. level.depth .. ".lua") then
		local chunk = love.filesystem.load(level.name .. "_" .. level.depth .. ".lua")
		chunk()
		setup_monsters_on_map_load()
		return true
	end
	return false
	
end

function setup_monsters_on_map_load()

	for x = 1, map_width do
		for y = 1, map_height do
			if map[x][y]:get_holding() and map[x][y]:get_holding() ~= player then
				map[x][y]:get_holding():set_x(x)
				map[x][y]:get_holding():set_y(y)
			end
		end
	end
	
end

function save_map()

	local text = ""
	text = text .. "map = {} for x = 1, 46 do map[x] = {} for y = 1, 33 do map[x][y] = {} end end\n\n"

	for x = 1, map_width do
		for y = 1, map_height do
			text = text .. "map[" .. x .. "][" .. y .. "] = Tile:new({"
			if map[x][y]:get_block_move() then text = text .. "block_move = true," end
			if map[x][y]:get_block_sight() then text = text .. "block_sight = true," end
			if map[x][y]:get_char() then text = text .. "char = \'" .. map[x][y]:get_char() .. "\'," end
			if map[x][y]:get_seen() then text = text .. "seen = true," end
			if map[x][y]:get_lit() then text = text .. "lit = false," end
			if map[x][y]:get_name() then text = text .. "name = \'" .. map[x][y]:get_name() .. "\'," end
			if map[x][y]:get_color() then
				local color = map[x][y]:get_color()
				text = text .. "color = {r=" .. color.r .. ",g=" .. color.g .. ",b=" .. color.b .. "},"
			end
			--- save items
			if map[x][y]:get_items() then
				local items = ""
				local item = false
				for i = 1, # map[x][y]:get_items() do
					item = save_item(map[x][y]:get_items()[i])
					if item:len() > 1 then items = items .. item end
				end
				text = text .. "items = {" .. items .. "},"
			end
			--- save creatures
			if map[x][y]:get_holding() and map[x][y]:get_holding() ~= player then
				local creat = save_creature(map[x][y]:get_holding())
				if creat:len() > 1 then					
					text = text .. "holding = " .. creat
				end
			end
			text = text .. "x = " .. x .. ",y = " .. y .. ","
			text = text .. "})\n"			
		end
	end
	
	--- save special rooms
	text = text .. "\n"
	text = text .. "map_special_rooms = { "
	if # map_special_rooms > 0 then
		for i = 1, # map_special_rooms do
			text = text .. "{x=" .. map_special_rooms[i].x .. ","
			text = text .. "y=" .. map_special_rooms[i].y .. ","
			text = text .. "w=" .. map_special_rooms[i].w .. ","
			text = text .. "h=" .. map_special_rooms[i].h .. ","
			text = text .. "enter=false,"
			text = text .. "message=\"" .. map_special_rooms[i].message .. "\",}, "
		end		
	end
	text = text .. " } \n"
	
	love.filesystem.write(level.name .. "_" .. level.depth .. ".lua", text)
	
end

function save_spell(spell)

	if not spell then return 'nil, ' end
	
	local text = ""
	text = text .. "game_spells["
	for i = 1, # game_spells do
		if spell == game_spells[i].name then
			text = text .. i .. "], "
			return text
		end
	end
	
	return ""

end

function save_item(item)

	if not item then return 'nil, ' end

	local text = ""
	text = text .. "Item:new("
	for i = 1, # game_items do
		if item:get_name() == game_items[i].name then
			text = text .. "game_items[" .. i .. "]), "
			return text
		end
	end
	
	return ""

end

function save_creature(creat)

	local text = ""
	text = text .. "Creature:new("
	for i = 1, # game_monsters do
		if creat:get_name() == game_monsters[i].name then
			text = text .. "game_monsters[" .. i .. "]), "
			return text
		end
	end
	
	return ""

end

function dijkstra_map(dx, dy)

	local dmap = {}
	for x = 1, map_width do
		dmap[x] = {}
		for y = 1, map_height do
			dmap[x][y] = 25
		end
	end
	
	dmap[dx][dy] = 0
	if not map[dx-1][dy]:get_block_move() then dmap[dx-1][dy] = 2 end
	if not map[dx+1][dy]:get_block_move() then dmap[dx-1][dy] = 2 end
	if not map[dx][dy-1]:get_block_move() then dmap[dx][dy-1] = 2 end
	if not map[dx][dy+1]:get_block_move() then dmap[dx][dy+1] = 2 end
	if not map[dx-1][dy-1]:get_block_move() then dmap[dx-1][dy-1] = 2 end
	if not map[dx-1][dy+1]:get_block_move() then dmap[dx-1][dy+1] = 2 end
	if not map[dx+1][dy-1]:get_block_move() then dmap[dx+1][dy-1] = 2 end
	if not map[dx+1][dy+1]:get_block_move() then dmap[dx+1][dy+1] = 2 end
	
	local changed = true
	local num = 1000
	
	local start_x = dx - 10
	local start_y = dy - 10
	local end_x = dx + 10
	local end_y = dy + 10
	
	if start_x < 2 then start_x = 2 end
	if start_y < 2 then start_y = 2 end
	if end_x > map_width - 1 then end_x = map_width - 1 end
	if end_y > map_height - 1 then end_y = map_height - 1 end
	
	repeat
	
		changed = false
		for x = start_x, end_x do
			for y = start_y, end_y do
				if not map[x][y]:get_block_move() then
					
					num = 1000
					
					if not map[x-1][y]:get_block_move() then if dmap[x-1][y] < num then num = dmap[x-1][y] end end
					if not map[x+1][y]:get_block_move() then if dmap[x+1][y] < num then num = dmap[x+1][y] end end
					
					if not map[x][y-1]:get_block_move() then if dmap[x][y-1] < num then num = dmap[x][y-1] end end
					if not map[x][y+1]:get_block_move() then if dmap[x][y+1] < num then num = dmap[x][y+1] end end
					
					if not map[x-1][y-1]:get_block_move() then if dmap[x-1][y-1] < num then num = dmap[x-1][y-1] end end
					if not map[x-1][y+1]:get_block_move() then if dmap[x-1][y+1] < num then num = dmap[x-1][y+1] end end
					if not map[x+1][y-1]:get_block_move() then if dmap[x+1][y-1] < num then num = dmap[x+1][y-1] end end
					if not map[x+1][y+1]:get_block_move() then if dmap[x+1][y+1] < num then num = dmap[x+1][y+1] end end
					
					if num < dmap[x][y] - 2 then dmap[x][y] = num + 1 changed = true end
					
				end
			end
		end
	
	until not changed
	
	return dmap

end

function stair_machine(dir)

	if level.name ~= 'Overworld' then
		next_level(dir)
		stair_cd = 3
	end		
	
end

function many_items_sorted(items)

	items_sorted = {}

	for i = 1, # items do
	
		if # items_sorted == 0 then
			table.insert(items_sorted, {item = items[i], quantity = 1})
		else
			local similar = false
			for k = 1, # items_sorted do
				if items_sorted[k].item:get_name() == items[i]:get_name() then
					items_sorted[k].quantity = items_sorted[k].quantity + 1
					similar = true
				end
				if similar then 
					break
				elseif not similar and k == # items_sorted then
					table.insert(items_sorted, {item = items[i], quantity = 1})
				end
			end
		end
		
	end
	
	items_sorted = sort_items_categories(items_sorted)

end

function sort_items_categories(items)

	local items = items
	local items_two = {}
	local index = 0
	local sortindex = 1

	repeat
	
		index = index + 1
		
		if index <= # items and index > 0 then
			if sortindex == 1 then
				if items[index].item:get_slot() and items[index].item:get_slot() == 'hand' then
					table.insert(items_two, items[index])
					table.remove(items, index)
					index = 0
				end
			elseif sortindex == 2 then
				if items[index].item:get_slot() and items[index].item:get_slot() ~= 'hand' then
					table.insert(items_two, items[index])
					table.remove(items, index)
					index = 0
				end
			elseif sortindex == 3 then
				if items[index].item:get_edible() then
					table.insert(items_two, items[index])
					table.remove(items, index)
					index = 0
				end
			elseif sortindex == 4 then
				if items[index].item:get_quaff() then
					table.insert(items_two, items[index])
					table.remove(items, index)
					index = 0
				end
			elseif sortindex == 5 then
				if items[index].item:get_read() then
					table.insert(items_two, items[index])
					table.remove(items, index)
					index = 0
				end
			else
				table.insert(items_two, items[index])
				table.remove(items, index)
				index = 0
			end
						
		end
		
		if index > # items then
			index = 0			
			sortindex = sortindex + 1
		end
	
	until # items == 0
	
	items = items_two
	return items

end

function player_mod_get(get)
	
	local amount = 0
	for i = 1, # player_mods do
		if player_mods[i][get] then
			amount = amount + player_mods[i][get] 
		end
	end
	return amount

end

function draw_intro()

	local start_x = 0
	local start_y = 0
	local width = 325
	local height = 265
	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x, start_y, width, height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('line', start_x+2, start_y+2, width-2, height-2)
	
	local text1 = 'From the northwest, out of an eerie cave, a strange wind blows.  The Jaaku Wind, capable of corrupting the minds of all living creatures, has quickly spread across Gensokyo.'
	local text2 = '  The Jaaku Wind for the most part only affects Youkai, however, humans who spend a considerable amount of time around Youkai may also be at risk.  '
	local text3 = '  Being born as a devout exterminator and keeper of the peace, it is your sworn duty to destroy the source of the Jaaku Wind as it flows from the eerie cave.'
	local text4 = '\n\n Go now exterminator, and save the lands of Gensokyo from certain destruction.'
	
	local text = text1 .. text2 .. text3 .. text4 .. '\n\n Press any key to continue...'
	
	love.graphics.printf(text, start_x + 4, start_y + 3, width - 4, 'left')
	
end

function draw_feats_gain()

	local start_x = 0
	local start_y = 0
	local width = 650
	local height = 470
	local font = love.graphics.getFont()
	local tw = 0
	local index = 1
	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x, start_y, width, height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('line', start_x+2, start_y+2, width-2, height-2)
	
	love.graphics.print("Feats:  Choose what feat you would like to gain.", start_x + 4, start_y + 4)
	
	for i = 1, # player_feats do
		if not player_feats[i].have then
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.print(alphabet[i] .. ": ", start_x + 10, start_y + (index * 30))
			love.graphics.setColor(204, 155, 63, 255)
			love.graphics.print(player_feats[i].name, start_x + 10 + font:getWidth(alphabet[i] .. ": "), start_y + (index * 30))
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.print(player_feats[i].desc, start_x + 20, start_y + (index * 30) + 15)
			index = index + 1
		end
	end

end

function draw_look()
	
	local x = look_cursor.x
	local y = look_cursor.y
	local message = ""

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('line', ascii_draw_point(look_cursor.x) - 2, ascii_draw_point(look_cursor.y) + 2, char_width, char_width)
	
	if map[x][y]:get_lit() then
		--- tile char and name
		message = message .. " " .. map[x][y]:get_char() .. "  -   "
		message = message .. map[x][y]:get_name()
		--- monster char and name
		if map[x][y]:get_holding() then
			message = message .. ",  " .. map[x][y]:get_holding():get_char()
			message = message .. "  -   " .. map[x][y]:get_holding():get_name()
		end
		--- item char and name
		if map[x][y]:get_items() then
			message = message .. ",  " .. map[x][y]:get_items()[1]:get_char()
			message = message .. "  -   " .. map[x][y]:get_items()[1]:get_pname()
		end
			
	elseif not map[x][y]:get_lit() and map[x][y]:get_seen() then
		message = message .. " " .. map[x][y]:get_char() .. "  -   "
		message = message .. map[x][y]:get_name()
	end
	
	love.graphics.print(message, 0, 0)

end

function draw_help()

	local start_x = 0
	local start_y = 0
	local width = 650
	local height = 471
	local font = love.graphics.getFont()
	local tw = 0
	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x, start_y, width, height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('line', start_x+2, start_y+2, width-2, height-2)
	
	love.graphics.print("Help File.  Press any key to close.", start_x + 4, start_y + 4)
	
	love.graphics.draw(help_img, start_x + 10, start_y + 30)

end

function draw_feats()

	local start_x = 0
	local start_y = 0
	local width = 650
	local height = 470
	local font = love.graphics.getFont()
	local tw = 0
	local index = 1
	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x, start_y, width, height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('line', start_x+2, start_y+2, width-2, height-2)
	
	love.graphics.print("Feats:  Press any key to return", start_x + 4, start_y + 4)
	
	for i = 1, # player_feats do
		if player_feats[i].have then
			love.graphics.setColor(204, 155, 63, 255)
			love.graphics.print(player_feats[i].name, start_x + 10, start_y + (index * 30))
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.print(player_feats[i].desc, start_x + 20, start_y + (index * 30) + 15)
			index = index + 1
		end
	end
	
end

function draw_skills()

	local start_x = 0
	local start_y = 0
	local width = 650
	local height = 470
	local index = 1
	local font = love.graphics.getFont()
	local tw = 0
	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x, start_y, width, height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('line', start_x+2, start_y+2, width-2, height-2)
	
	love.graphics.print("Skills: Press any key to return", start_x + 4, start_y + 4)
	
	
	for k, v in pairs(player_skills) do
	
		index = index + 1
		--- key
		love.graphics.setColor(204, 155, 63, 255)
		love.graphics.print(k .. " : ", start_x + 10, start_y + index * 16)
		--- value
		love.graphics.setColor(255, 255, 255, 255)
		tw = font:getWidth(k .. " : ")
		love.graphics.print(v, start_x + 10 + tw, start_y + index * 16)
	
	end

end

function draw_shop()

	local start_x = 0
	local start_y = 0
	local width = 300
	local height = (# shop_items + 2) * 15 + 8
	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x, start_y, width, height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('line', start_x+2, start_y+2, width-2, height-2)
	
	love.graphics.print("-FOR SALE-", start_x + 24, start_y + 4)
	love.graphics.print("Choose what to buy, ESC to cancel", start_x + 24, start_y + ((# shop_items +1)) * 15 + 4)
	
	for i = 1, # shop_items do
	
		local message = ""
		message = message .. alphabet[i] .. ": "
		message = message .. shop_items[i].name .. ", "
		message = message .. "Cost: " .. shop_items[i].cost
		love.graphics.print(message, start_x + 4, start_y + (i) * 15 + 4)
	end

end

function draw_spells()

	local start_x = 0
	local start_y = 0
	local width = 300
	local height = (# player_spells + 2) * 15 + 8
	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x, start_y, width, height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('line', start_x+2, start_y+2, width-2, height-2)
	
	love.graphics.print("Cast what?", start_x + 24, start_y + 4)
	love.graphics.print("Press ENTER to cancel", start_x + 24, start_y + ((# player_spells) + 1) * 15 + 4)
	
	for i = 1, # player_spells do
		local message = ""
		message = message .. alphabet[i] .. ": "
		message = message .. player_spells[i].name .. ", "
		message = message .. "MP Cost:" .. player_spells[i].mp_cost
		love.graphics.print(message, start_x + 4, start_y + (i) * 15 + 4)
	end

end

function draw_many_item_pickup()

	local start_x = 0
	local start_y = 0
	local width = 300
	local height = ((# items_sorted + 2) * 15 + 8)
	local items_map = map[player:get_x()][player:get_y()]:get_items()
	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x, start_y, width, height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('line', start_x+2, start_y+2, width-2, height-2)
	
	love.graphics.print("Pick up what?", start_x + 24, start_y + 4)
	love.graphics.print("Press ENTER to pickup marked items...", start_x + 24, start_y + ((# items_sorted) + 1) * 15 + 4)
	
	for i = 1, # items_sorted do
		local message = ""
		
		if pickup_many_items_choice[alphabet[i]] then
			message = message .. '*: '
		else
			message = message .. alphabet[i] .. ": " 
		end
		
		if items_sorted[i].quantity == 1 then
			message = message .. "a " .. items_sorted[i].item:get_pname()
		else
			message = message .. tostring(items_sorted[i].quantity) .. " " .. items_sorted[i].item:get_pname()
		end
		
		love.graphics.print(message, start_x + 4, start_y + (i) * 15 + 4)
	end

end

function player_message()

	local start_x = 0
	local start_y = 470
	local width = 800
	local height = 130
	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x, start_y, width, height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('line', start_x+2, start_y+2, width-2, height-2)
	
	if # messages > 0 then
		for i = 1, # messages do
			love.graphics.print(messages[i], start_x + 10, start_y + height - (i * 20))
			if i >= 6 then break end
		end
	end
	
end

function player_hud()

	local start_x = 650
	local start_y = 0
	local width = 150
	local height = 470
	local font = love.graphics.getFont()
	local tw = 0
	local per = 0
	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x, start_y, width, height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('line', start_x+2, start_y+2, width-2, height-2)
	
	---name
	love.graphics.setColor(218, 222, 95, 255)
	love.graphics.print(player_name, start_x + 10, start_y + 10)
	love.graphics.setColor(255, 255, 255, 255)
	--- level
	love.graphics.setColor(204, 155, 63, 255)
	love.graphics.print("Level : ", start_x + 10, start_y + 25)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(player_level, start_x + 10 + font:getWidth("Level : "), start_y + 25)
	--- XP
	love.graphics.setColor(204, 155, 63, 255)
	love.graphics.print("XP : ", start_x + 10, start_y + 40)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(player_exp, start_x + 10 + font:getWidth("XP : "), start_y + 40)
	
	--- stats
	tw = font:getWidth("STR : ")
	love.graphics.setColor(204, 155, 63, 255)
	love.graphics.print("STR : ", start_x + 10, start_y + 65)
	love.graphics.print("DEX : ", start_x + 10, start_y + 80)
	love.graphics.print("INT : ", start_x + 70, start_y + 65)
	love.graphics.print("CON : ", start_x + 70, start_y + 80)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(player_stats.str, start_x + 10 + tw, start_y + 65)
	love.graphics.print(player_stats.dex, start_x + 10 + tw, start_y + 80)
	love.graphics.print(player_stats.int, start_x + 70 + tw, start_y + 65)
	love.graphics.print(player_stats.con, start_x + 70 + tw, start_y + 80)
	
	--- armor
	love.graphics.setColor(204, 155, 63, 255)
	love.graphics.print("Armor : ", start_x + 10, start_y + 110)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(player:get_armor(), start_x + 10 + font:getWidth("Armor : "), start_y + 110)
	--- evasion
	love.graphics.setColor(204, 155, 63, 255)
	love.graphics.print("Evasion : ", start_x + 10, start_y + 125)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(player:get_evasion(), start_x + 10 + font:getWidth("Evasion : "), start_y + 125)
	
	--- HP
	love.graphics.setColor(204, 155, 63, 255)
	love.graphics.print("HP : ", start_x + 10, start_y + 155)
	love.graphics.setColor(255, 255, 255, 255)
	per = (player:get_hp_cur() / player:get_hp_max()) * 100
	if per >= 70 then
		love.graphics.setColor(95, 222, 106, 255)
	elseif per < 70 and per > 25 then
		love.graphics.setColor(216, 222, 95, 255)
	elseif per < 55 and per >= 25 then
		love.graphics.setColor(222, 190, 95, 255)
	else
		love.graphics.setColor(222, 95, 95, 255)
	end
	love.graphics.print(player:get_hp_cur() .. "/" .. player:get_hp_max(), start_x + 10 + font:getWidth("HP : "), start_y + 155)
	love.graphics.setColor(255, 255, 255, 255)
	--- Mana
	love.graphics.setColor(204, 155, 63, 255)
	love.graphics.print("MP : ", start_x + 10, start_y + 170)
	love.graphics.setColor(255, 255, 255, 255)
	per = (player:get_mana_cur() / player:get_mana_max()) * 100
	if per >= 70 then
		love.graphics.setColor(95, 222, 106, 255)
	elseif per < 70 and per > 25 then
		love.graphics.setColor(216, 222, 95, 255)
	elseif per < 55 and per >= 25 then
		love.graphics.setColor(222, 190, 95, 255)
	else
		love.graphics.setColor(222, 95, 95, 255)
	end
	love.graphics.print(player:get_mana_cur() .. "/" .. player:get_mana_max(), start_x + 10 + font:getWidth("MP : "), start_y + 170)
	love.graphics.setColor(255, 255, 255, 255)
	
	--- is the player hungry or starving yet?
	if player_food.level <= player_food.hungry and player_food.level > player_food.starving then
		love.graphics.print('Hungry', start_x + 10, start_y + 200)
	elseif player_food.level <= player_food.starving and player_food.level > player_food.weak then
		love.graphics.print('Starving', start_x + 10, start_y + 200)
	elseif player_food.level <= player_food.weak then
		love.graphics.print('Weak', start_x + 10, start_y + 200)
	end
	
	--- encumbrance
	if player_encumbrance == 1 then
		love.graphics.print("Burdened", start_x + 10, start_y + 215)
	elseif player_encumbrance == 2 then
		love.graphics.print("Strained", start_x + 10, start_y + 215)
	end
	
	--- modifiers
	for i = 1, # player_mods do
		love.graphics.print(player_mods[i].name, start_x + 10, start_y + 230 + ((i - 1) * 15))
	end
	
	love.graphics.print(player_stances[player_stance], start_x + 10, start_y + 370)
	
	--- gold
	love.graphics.setColor(204, 155, 63, 255)
	love.graphics.print("Gold : ", start_x + 10, start_y + 400)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(player_gold, start_x + 10 + font:getWidth("Gold : "), start_y + 400)
	--- level name and depth
	love.graphics.setColor(204, 155, 63, 255)
	love.graphics.print(level.name, start_x + 10, start_y + 430)
	love.graphics.print("Depth : ", start_x + 10, start_y + 445)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(level.depth, start_x + 10 + font:getWidth("Depth : "), start_y + 445)
	
end

function draw_inventory()

	local start_x = 0
	local start_y = 0
	local width = 300
	local height = (# player_inventory + 2) * 15 + 8
	local height_add = 0
	local print_add = 0
	local draw_title = {false, false, false, false, false, false}
	local font = love.graphics.getFont()
	local tw = 0
	
	--- calculate the height of the window
	for i = 1, # player_inventory do
		if player_inventory[i].item:get_slot() == 'hand' then		
			if not draw_title[1] then
				draw_title[1] = true
				height_add = height_add + 1
			end
		elseif player_inventory[i].item:get_slot() and player_inventory[i].item:get_slot() ~= 'hand' then
			if not draw_title[2] then
				draw_title[2] = true
				height_add = height_add + 1
			end
		elseif player_inventory[i].item:get_edible() then
			if not draw_title[3] then
				draw_title[3] = true
				height_add = height_add + 1		
			end
		elseif player_inventory[i].item:get_read() then
			if not draw_title[4] then
				draw_title[4] = true
				height_add = height_add + 1
			end
		elseif player_inventory[i].item:get_quaff() then
			if not draw_title[5] then
				draw_title[5] = true
				height_add = height_add + 1
			end
		else
			if not draw_title[6] then
				draw_title[6] = true
				height_add = height_add + 1
			end
		end
	end
	
	height = (# player_inventory + 2 + height_add) * 15 + 8
	draw_title = {false, false, false, false, false, false}
	
	--- start the real drawing now
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x, start_y, width, height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('line', start_x+2, start_y+2, width-2, height-2)
	
	love.graphics.setColor(218, 222, 95, 255)
	if inventory_action == 'look' then
		love.graphics.print("Inventory", start_x + 24, start_y + 4)
		love.graphics.print("Press any key to continue...", start_x + 24, height - 19)
	elseif inventory_action == 'drop' then
		love.graphics.print("Drop what?", start_x + 24, start_y + 4)
		love.graphics.print("Press ENTER to drop marked items...", start_x + 24, height - 19)
	elseif inventory_action == 'wield' then
		love.graphics.print("Wield what?", start_x + 24, start_y + 4)
		love.graphics.print("ENTER for empty hands, ESC to cancel", start_x + 24, height - 19)
	elseif inventory_action == 'wear' then
		love.graphics.print("Wear what?", start_x + 24, start_y + 4)
		love.graphics.print("Choose what to wear, ESC to cancel", start_x + 24, height - 19)
	elseif inventory_action == 'remove' then
		love.graphics.print("Remove what?", start_x + 24, start_y + 4)
		love.graphics.print("Choose what to remove, ESC to cancel", start_x + 24, height - 19)
	elseif inventory_action == 'quaff' then
		love.graphics.print("Quaff what?", start_x + 24, start_y + 4)
		love.graphics.print("Choose what to quaff, ESC to cancel", start_x + 24, height - 19)
	elseif inventory_action == 'cook' then
		love.graphics.print("Cook what?", start_x + 24, start_y + 4)
		love.graphics.print("Choose what to cook, ESC to cancel", start_x + 24, height - 19)
	elseif inventory_action == 'eat' then
		love.graphics.print("Eat what?", start_x + 24, start_y + 4)
		love.graphics.print("Choose what to eat, ESC to cancel", start_x + 24, height - 19)
	elseif inventory_action == 'sell' then
		love.graphics.print("Sell what?", start_x + 24, start_y + 4)
		love.graphics.print("Choose what to sell, ESC to cancel", start_x + 24, height - 19)
	elseif inventory_action == 'read' then
		love.graphics.print("Read what?", start_x + 24, start_y + 4)
		love.graphics.print("Choose what to read, ESC to cancel", start_x + 24, height - 19)
	elseif inventory_action == 'apply' then
		love.graphics.print("Apply what?", start_x + 24, start_y + 4)
		love.graphics.print("Choose what to apply, ESC to cancel", start_x + 24, height - 19)
	end
	love.graphics.setColor(255, 255, 255, 255)
	
	local message = ""
	
	--- inventory 
	for i = 1, # player_inventory do
	
		--- titles
		love.graphics.setColor(204, 155, 63, 255)
		if player_inventory[i].item:get_slot() == 'hand' then			
			if not draw_title[1] then
				love.graphics.print("Weapons -   )", start_x + 10, start_y + (i + print_add) * 15 + 4)
				draw_title[1] = true
				print_add = print_add + 1
			end
		elseif player_inventory[i].item:get_slot() and player_inventory[i].item:get_slot() ~= 'hand' then
			if not draw_title[2] then
				love.graphics.print("Armor -   ] , [", start_x + 10, start_y + (i + print_add) * 15 + 4)
				draw_title[2] = true
				print_add = print_add + 1
			end
		elseif player_inventory[i].item:get_edible() then
			if not draw_title[3] then
				love.graphics.print("Comestibles -   %", start_x + 10, start_y + (i + print_add) * 15 + 4)
				draw_title[3] = true
				print_add = print_add + 1
			end
		elseif player_inventory[i].item:get_read() then
			if not draw_title[4] then
				love.graphics.print("Scrolls -   ?", start_x + 10, start_y + (i + print_add) * 15 + 4)
				draw_title[4] = true
				print_add = print_add + 1
			end
		elseif player_inventory[i].item:get_quaff() then
			if not draw_title[5] then
				love.graphics.print("Potions -   !", start_x + 10, start_y + (i + print_add) * 15 + 4)
				draw_title[5] = true
				print_add = print_add + 1
			end
		else
			if not draw_title[6] then
				love.graphics.print("Miscellaneous", start_x + 10, start_y + (i + print_add) * 15 + 4)
				draw_title[6] = true
				print_add = print_add + 1
			end
		end
		love.graphics.setColor(255, 255, 255, 255)
		
		--- items
		message = ""
	
		if inventory_action == 'look' then
			message = message .. alphabet[i] .. ": "
		elseif inventory_action == 'drop' or inventory_action == 'apply' or inventory_action == 'sell' or inventory_action == 'read' or inventory_action == 'eat' or inventory_action == 'wear' or inventory_action == 'wield' or inventory_action == 'quaff' or inventory_action == 'cook' then
			if inventory_to_drop[alphabet[i]] then
				message = message .. '[*] '
			else
				message = message .. alphabet[i] .. ": "
			end
		end
	
		if player_inventory[i].quantity == 1 then
			message = message ..  "a " .. player_inventory[i].item:get_pname()
		else
			message = message .. tostring(player_inventory[i].quantity) .. " " .. player_inventory[i].item:get_pname()
		end	
		
		if inventory_action == 'sell' then
			message = message .. ", Sell For: 5"
		end
		
		love.graphics.print(message, start_x + 4, start_y + (i + print_add) * 15 + 4)
	end
	
	--- equipment
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x + width + start_x, start_y, width, 8 * 15 + 8)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('line', start_x+2 + width + start_x, start_y+2, width-2, 8 * 15 + 8 - 2)
	
	love.graphics.setColor(218, 222, 95, 255)
	love.graphics.print("Equipment", start_x + width + start_x + 24, start_y + 4)	
	love.graphics.setColor(204, 155, 63, 255)
	love.graphics.print("---Armor---", start_x + width + start_x + 24, start_y + 15 + 4)
	love.graphics.setColor(255, 255, 255, 255)
	
	--- head slot
	if inventory_action == 'remove' then 
		message = 'a: ' 
	else 
		message = "Head: " 
	end
	love.graphics.setColor(204, 155, 63, 255)
	love.graphics.print(message, start_x + width + start_x + 4, start_y + 30 + 4)
	love.graphics.setColor(255, 255, 255, 255)
	tw = font:getWidth(message)
	if player_equipment.head then 
		message = player_equipment.head:get_pname() 
	else
		message = ""
	end
	love.graphics.print(message, start_x + width + start_x + 4 + tw, start_y + 30 + 4)
	
	--- body
	if inventory_action == 'remove' then 
		message = 'b: ' 
	else 
		message = "Body: " 
	end
	love.graphics.setColor(204, 155, 63, 255)
	love.graphics.print(message, start_x + width + start_x + 4, start_y + 45 + 4)
	love.graphics.setColor(255, 255, 255, 255)
	tw = font:getWidth(message)
	if player_equipment.torso then 
		message = player_equipment.torso:get_pname() 
	else
		message = ""
	end
	love.graphics.print(message, start_x + width + start_x + 4 + tw, start_y + 45 + 4)
	
	--- legs
	if inventory_action == 'remove' then 
		message = 'c: ' 
	else 
		message = "Legs: " 
	end
	love.graphics.setColor(204, 155, 63, 255)
	love.graphics.print(message, start_x + width + start_x + 4, start_y + 60 + 4)
	love.graphics.setColor(255, 255, 255, 255)
	tw = font:getWidth(message)
	if player_equipment.legs then 
		message = player_equipment.legs:get_pname() 
	else 
		message = ""
	end
	love.graphics.print(message, start_x + width + start_x + 4 + tw, start_y + 60 + 4)
	
	--- feet
	if inventory_action == 'remove' then 
		message = 'd: ' 
	else 
		message = "Feet: " 
	end
	love.graphics.setColor(204, 155, 63, 255)
	love.graphics.print(message, start_x + width + start_x + 4, start_y + 75 + 4)
	love.graphics.setColor(255, 255, 255, 255)
	tw = font:getWidth(message)
	if player_equipment.feet then 
		message = player_equipment.feet:get_pname() 
	else
		message = ""
	end
	love.graphics.print(message, start_x + width + start_x + 4 + tw, start_y + 75 + 4)
	
	love.graphics.setColor(218, 222, 95, 255)
	love.graphics.print("---Weapon---", start_x + width + start_x + 24, start_y + 90 + 4)
	love.graphics.setColor(255, 255, 255, 255)
	
	if inventory_action == 'remove' then 
		message = 'e: ' 
	else
		message = "Hands: " 
	end
	love.graphics.setColor(204, 155, 63, 255)
	love.graphics.print(message, start_x + width + start_x + 4, start_y + 105 + 4)
	love.graphics.setColor(255, 255, 255, 255)
	tw = font:getWidth(message)
	if player_equipment.hand then 
		message = player_equipment.hand:get_pname() 
	else
		message = ""
	end
	love.graphics.print(message, start_x + width + start_x + 4 + tw, start_y + 105 + 4)

end

function monster_corpse_check(mon)

	if mon:get_corpse() then
		for i = 1, # game_items do
			if game_items[i].corpse == mon:get_corpse() then
				if math.random(1, 100) <= 35 then
				
					--- drop corpse
					local items = {}
					if map[mon:get_x()][mon:get_y()]:get_items() then
						items = map[mon:get_x()][mon:get_y()]:get_items()
					end
					table.insert(items, Item:new(game_items[i]))
					map[mon:get_x()][mon:get_y()]:set_items(items)
					break
					
				end
			end
		end
	end

end

function player_held_weight()

	local weight = 0
	for i = 1, # player_inventory do
		weight = weight + (player_inventory[i].item:get_weight() * player_inventory[i].quantity)
	end
	return weight

end

function player_feat_search(skill)

	local amnt = 0
	for i = 1, # player_feats do
		if player_feats[i].have and player_feats[i][skill] then
			amnt = amnt + player_feats[i][skill]
		end
	end
	return amnt

end

function player_fov()

	if level.name ~= 'Overworld' then map_calc_fov(player:get_x(), player:get_y(), world_see_distance)		
	elseif level.name == 'Overworld' then map_overworld_fov(player:get_x(), player:get_y(), 2) end
	
end

function shop_load_items(shop)

	if shop == 'Weapon' then
		shop_items = {	{ name = 'Broom', cost = 25, item = shop_find_game_item('Broom') },
						{ name = 'Gohei Stick', cost = 45, item = shop_find_game_item('Gohei Stick') },
						{ name = 'Dagger', cost = 125, item = shop_find_game_item('Dagger') },
						{ name = 'Katana', cost = 250, item = shop_find_game_item('Katana') },
						{ name = 'Hatchet', cost = 25, item = shop_find_game_item('Hatchet') },
						}
	elseif shop == 'Armor' then
		shop_items = {	{ name = 'Leather Vest', cost = 50, item = shop_find_game_item('Leather Vest') },
						{ name = 'Cloth Skirt', cost = 75, item = shop_find_game_item('Cloth Skirt') },
						{ name = 'Leahter Shoes', cost = 75, item = shop_find_game_item('Leather Shoes') },
						{ name = 'Silk Bonnet', cost = 85, item = shop_find_game_item('Silk Bonnet') },
						}
	elseif shop == 'Potion' then
		shop_items = {	{ name = 'Potion of Gain', cost = 350, item = shop_find_game_item('Potion of Gain') },
						{ name = 'Potion of Healing', cost = 50, item = shop_find_game_item('Potion of Healing') },
						}
	elseif shop == 'Aki' then
		shop_items = {	{ name = 'Sweet Potato', cost = 55, item = shop_find_game_item('Sweet Potato') }, }
	elseif shop == 'Rino' then
		shop_items = {	{ name = 'Police Baton', cost = 350, item = shop_find_game_item('Police Baton') },
						{ name = 'Bullet-Proof Vest', cost = 500, item = shop_find_game_item('Bullet-Proof Vest') },
						{ name = 'Game Boy', cost = 10, item = shop_find_game_item('Game Boy') },
						}
	end
	
end

function shop_find_game_item(name)

	for i = 1, # game_items do
		if name == game_items[i].name then
			return Item:new(game_items[i])
		end
	end
	
	return Item:new(game_items[#game_items])

end

function map_special_rooms_check()

	if # map_special_rooms > 0 then
		for i = 1, # map_special_rooms do
			if player:get_x() >= map_special_rooms[i].x and player:get_x() <= map_special_rooms[i].x + map_special_rooms[i].w and
			   player:get_y() >= map_special_rooms[i].y and player:get_y() <= map_special_rooms[i].y + map_special_rooms[i].h then
				if not map_special_rooms[i].enter then
					map_special_rooms[i].enter = true
					message_add(map_special_rooms[i].message)
				end
			elseif player:get_x() < map_special_rooms[i].x or player:get_x() > map_special_rooms[i].x + map_special_rooms[i].w or
			       player:get_y() < map_special_rooms[i].y or player:get_y() > map_special_rooms[i].y + map_special_rooms[i].h then
					map_special_rooms[i].enter = false
			end
		end
	end

end

Creature = Class('Creature')
function Creature:initialize(arg)

	self.name = arg.name or 'Monster'
	self.hp_max = arg.hp_max or 125
	self.hp_cur = arg.hp_cur or self.hp_max
	self.hp_regen = arg.hp_regen or 100
	self.hp_regen_timer = arg.hp_regen_timer or self.hp_regen
	self.mana_max = arg.mana_max or 100
	self.mana_cur = arg.mana_cur or self.mana_max
	self.mana_regen = arg.mana_regen or 25
	self.mana_regen_timer = arg.mana_regen_timer or self.mana_regen
	self.food_tick = 25
	self.base_damage = arg.base_damage or {15, 25}
	self.bullet = arg.bullet or 1
	self.armor = arg.armor or 1
	self.evasion = arg.evasion or 0
	self.speed = arg.speed or 10
	self.shop = arg.shop or false
	self.sell = arg.sell or false
	self.turn_cd = arg.turn_cd or 1
	self.x = arg.x or 1
	self.y = arg.y or 1
	self.team = arg.team or 1
	self.char = arg.char or 'M'
	self.ai = arg.ai or 'normal'
	self.seen_player = arg.seen_player or false
	self.seen_player_cd = 10
	self.exp = arg.exp or 10
	self.unique = arg.unique or false
	self.corpse = arg.corpse or false
	self.color = arg.color or function () love.graphics.setColor(255, 255, 255, 255) end
	
end

function Creature:ai_take_turn(moved)

	self.turn_cd = self.turn_cd - 1
	self.hp_regen_timer = self.hp_regen_timer - 1
	self.mana_regen_timer = self.mana_regen_timer - 1
	self.food_tick = self.food_tick - 1
	
	if self.turn_cd < 1 or moved then
		for i = self.turn_cd, 0 do
			
			--- check if the player is still alive before moving any more monsters
			if player_dead then return end
		
			self.turn_cd = self.speed
			if self == player then 
				--- speed changes
				self.turn_cd = self.speed - player_stats.dex - player_mod_get('speed') - player_feat_search('speed')
				--- stance speed changes (removed)
				if player_stance == 1 then self.turn_cd = self.turn_cd + 0 end
				if player_stance == 2 then self.turn_cd = self.turn_cd + 0 end
				if player_stance == 4 then self.turn_cd = self.turn_cd - 0 end
				if player_stance == 5 then self.turn_cd = self.turn_cd - 0 end
				--- encumbrance speed changes
				self.turn_cd = self.turn_cd + player_encumbrance * 3
				
				--- feat hp regen
				self.hp_regen_timer = self.hp_regen_timer - player_feat_search('hpregen')
				--- feat mana regen
				self.mana_regen_timer = self.mana_regen_timer - player_feat_search('manaregen')
			end
			if self.name ~= "Player" then
			
				--- enemy speed
				self.turn_cd = self.speed + ((player:get_speed() - player_stats.dex - player_mod_get('speed') - player_feat_search('speed')) * -1)
			
				--- enemy ai
				if self.ai == 'wander' then
					Creature.ai_wander(self)
				elseif self.ai == 'normal' then
					Creature.ai_normal(self)
				elseif self.ai == 'ranged' then
					Creature.ai_ranged(self)
				elseif self.ai == 'melee' then
					Creature.ai_melee(self)
				end
				
			end
		end
	end
	
	if self.hp_regen_timer < 1 and self == player then
		self.hp_regen_timer = self.hp_regen - player_stats.con
		self.hp_cur = self.hp_cur + math.ceil(player_stats.con / 3)
		if self.hp_cur > self.hp_max then self.hp_cur = self.hp_max end
	end
	if self.mana_regen_timer < 1 and self == player then
		self.mana_regen_timer = self.mana_regen - player_stats.int
		self.mana_cur = self.mana_cur + math.ceil(player_stats.int)
		if self.mana_cur > self.mana_max then self.mana_cur = self.mana_max end
	end
	if self.food_tick < 1 and self == player then
		player_food.level = player_food.level - 1
		self.food_tick = 25
	end
	
	if self == player then
		for i = 1, # player_mods do
			if i > # player_mods then break end
			player_mods[i].turn = player_mods[i].turn - 1
			if player_mods[i].turn < 1 then
				table.remove(player_mods, i)
				i = i - 1
			end
		end
	end
	
	return {x = self.x, y = self.y}

end

function Creature:armor_change(amnt)

	self.armor = self.armor + amnt
	
end

function Creature:base_dam_change(amnt)

	self.base_damage[1] = self.base_damage[1] + amnt
	self.base_damage[2] = self.base_damage[2] + amnt

end

function Creature:levelup()

	if player_exp >= player_level^5 + 200 then
	
		local message = "You've grown stronger."
	
		player_exp = 0
		player_level = player_level + 1
		
		if player_level == 3 then
			feats_gain_open = true
		elseif player_level == 6 then
			feats_gain_open = true
		elseif player_level == 9 then
			feats_gain_open = true
		end
		
		self.hp_max = self.hp_max + player_stats.con * 5
		self.mana_max = self.mana_max + player_stats.int * 5
		self.base_damage[1] = self.base_damage[1] + player_stats.str * 3
		self.base_damage[2] = self.base_damage[2] + player_stats.str * 3
		
		for i = 1, # player_spells_learn do
			if player_spells_learn[i].level == player_level then
				table.insert(player_spells, player_spells_learn[i].spell)
				table.remove(player_spells_learn, i)
				break
			end
		end
		
		--- athletics
		if player_feat_search('athletics') > 0 then
			print('search')
			if math.random(1, 100) <= 30 then
				message = message .. "  Your muscles feel stronger."
				player_stats.str = player_stats.str + 1
			end
			if math.random(1, 100) <= 30 then
				message = message .. "  Your body feels more flexible."
				player_stats.dex = player_stats.dex + 1
			end
		end
		
		message_add(message)
		
	end

end

function Creature:ai_melee()

	local moved = false
	if map[player:get_x()][player:get_y()]:get_lit() and map[self.x][self.y]:get_lit() then
		self.seen_player = true
		self.seen_player_cd = 4
	end
	if self.seen_player then
		self.seen_player_cd = self.seen_player_cd - 1
		if self.seen_player_cd < 1 then self.seen_player = false end
		
		if path_to_player[player:get_x()][player:get_y()] ~= 0 then
			path_to_player = dijkstra_map(player:get_x(), player:get_y())
		end
		
		--- move and bump player
		if not moved then
			if path_to_player[self.x-1][self.y] < path_to_player[self.x][self.y] and not moved then Creature.move(self, -1, 0) moved = true end
			if path_to_player[self.x+1][self.y] < path_to_player[self.x][self.y] and not moved then Creature.move(self, 1, 0) moved = true end
			if path_to_player[self.x][self.y-1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, 0, -1) moved = true end
			if path_to_player[self.x][self.y+1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, 0, 1) moved = true end
			if path_to_player[self.x-1][self.y-1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, -1, -1) moved = true end
			if path_to_player[self.x-1][self.y+1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, -1, 1) moved = true end
			if path_to_player[self.x+1][self.y-1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, 1, -1) moved = true end
			if path_to_player[self.x+1][self.y+1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, 1, 1) moved = true end
		end
		
	else
		Creature.move(self, math.random(-1,1), math.random(-1,1))
	end

end

function Creature:ai_ranged()

	local moved = false
	if map[player:get_x()][player:get_y()]:get_lit() and map[self.x][self.y]:get_lit() then
		self.seen_player = true
		self.seen_player_cd = 4
	end
	if self.seen_player then
	
		if distance(self.x, self.y, player:get_x(), player:get_y()) > 3 then
			--- fire danmaku at the player if we can
			local can_hit = false
			local dx = 0
			local dy = 0			
			local dam = math.ceil(math.random(self.base_damage[1], self.base_damage[2]) / 3)
			can_hit, dx, dy = Creature.enemy_can_hit_danmaku(self)
			
			if can_hit then
				enemy_danmaku_fire(self.x, self.y, dx, dy, self.bullet, dam, self.name)
				moved = true
			end	
			--- cant fire danmaku, move instead
			if not moved then
				Creature.move(self, math.random(-1,1), math.random(-1,1))
			end
		--- too close to player, run away and fire danmaku at the same time
		else
			--- movement portion
			local dx = 0
			local dy = 0
			if self.x > player:get_x() then
				dx = 1
			elseif self.x < player:get_x() then
				dx = -1
			end
			if self.y > player:get_y() then
				dy = 1
			elseif self.y < player:get_y() then
				dy = -1
			end
			Creature.move(self, dx, dy)
			--- danmaku portion
			local can_hit = false
			local dx = 0
			local dy = 0			
			local dam = math.ceil(math.random(self.base_damage[1], self.base_damage[2]) / 3)
			can_hit, dx, dy = Creature.enemy_can_hit_danmaku(self)
			
			if can_hit then
				enemy_danmaku_fire(self.x, self.y, dx, dy, self.bullet, dam, self.name)
				moved = true
			end	
		end
		
	else
		Creature.move(self, math.random(-1,1), math.random(-1,1))
	end

end

function Creature:ai_wander()

	local dx = math.random(-1, 1)
	local dy = math.random(-1, 1)
	Creature.move(self, dx, dy)

end

function Creature:enemy_can_hit_danmaku()

	local can_hit = false
	local dx = 0
	local dy = 0
	
	--- is the path to the player free?
	if not map[self.x][self.y]:get_lit() then
		return false, 0, 0
	end
	
	--- vertical firing
	if self.x == player:get_x() and self.y ~= player:get_y() then
		if self.y > player:get_y() then
			dy = -1
		else
			dy = 1
		end
		can_hit = true
		return can_hit, dx, dy
	end
	
	--- horizontal firing
	if self.y == player:get_y() and self.x ~= player:get_x() then
		if self.x > player:get_x() then	
			dx = -1
		else
			dx = 1
		end
		can_hit = true
		return can_hit, dx, dy
	end
	
	--- diagonal firing
	for d = 1, 8 do
		
		if self.x - d == player:get_x() then
			if self.y - d == player:get_y() then
				dx = -1
				dy = -1
				can_hit = true
				return can_hit, dx, dy
			elseif self.y + d == player:get_y() then
				dx = -1
				dy = 1
				can_hit = true
				return can_hit, dx, dy
			end
		end
		
		if self.x + d == player:get_x() then
			if self.y - d == player:get_y() then
				dx = 1
				dy = -1
				can_hit = true
				return can_hit, dx, dy
			elseif self.y + d == player:get_y() then
				dx = 1
				dy = 1
				can_hit = true
				return can_hit, dx, dy
			end
		end
		
	end
		
	return false, 0, 0
	
end

function Creature:ai_normal()

	local moved = false
	if map[player:get_x()][player:get_y()]:get_lit() and map[self.x][self.y]:get_lit() then
		self.seen_player = true
		self.seen_player_cd = 4
	end
	if self.seen_player then
		self.seen_player_cd = self.seen_player_cd - 1
		if self.seen_player_cd < 1 then self.seen_player = false end
		
		if path_to_player[player:get_x()][player:get_y()] ~= 0 then
			path_to_player = dijkstra_map(player:get_x(), player:get_y())
		end
		
		--- fire danmaku at player if we can
		if math.random(1, 100) >= 75 then
			local can_hit = false
			local dx = 0
			local dy = 0			
			local dam = math.ceil(math.random(self.base_damage[1], self.base_damage[2]) / 3)
			can_hit, dx, dy = Creature.enemy_can_hit_danmaku(self)
			
			if can_hit then
				enemy_danmaku_fire(self.x, self.y, dx, dy, self.bullet, dam, self.name)
				moved = true
			end		
		end
		
		--- move and bump player
		if not moved then
			if path_to_player[self.x-1][self.y] < path_to_player[self.x][self.y] and not moved then Creature.move(self, -1, 0) moved = true end
			if path_to_player[self.x+1][self.y] < path_to_player[self.x][self.y] and not moved then Creature.move(self, 1, 0) moved = true end
			if path_to_player[self.x][self.y-1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, 0, -1) moved = true end
			if path_to_player[self.x][self.y+1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, 0, 1) moved = true end
			if path_to_player[self.x-1][self.y-1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, -1, -1) moved = true end
			if path_to_player[self.x-1][self.y+1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, -1, 1) moved = true end
			if path_to_player[self.x+1][self.y-1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, 1, -1) moved = true end
			if path_to_player[self.x+1][self.y+1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, 1, 1) moved = true end
		end
		
	else
		Creature.move(self, math.random(-1,1), math.random(-1,1))
	end

end

function Creature:move(dx, dy)

	local new_x = self.x + dx
	local new_y = self.y + dy
	if not map[new_x][new_y]:get_block_move() then
		if not map[new_x][new_y]:get_holding() then
			map[new_x][new_y]:set_holding(map[self.x][self.y]:get_holding())
			map[self.x][self.y]:set_holding(nil)
			self.x = new_x
			self.y = new_y

			--- Tile messages and modifiers for when the player
			--- walks over them, and also player FoV
			if self == player then
			
				player_fov()
				map_special_rooms_check()
				
				--- update last move
				player_last_move = {x = dx, y = dy}
			
				--- tile modifiers and message
				if level.name ~= 'Overworld' then
					if map[self.x][self.y]:get_name() == 'Water' then
						message_add("You step into the cool water.  You get wet.")
						add_modifier({name = 'Wet', turn = 50, armor = -2})
					elseif map[self.x][self.y]:get_name() == 'Futon' then
						message_add("You step onto the comfy futon.")
					elseif map[self.x][self.y]:get_name() == 'Bed' then
						message_add("You climb onto the comfy bed.")
					elseif map[self.x][self.y]:get_name() == 'Cooking Pot' then
						message_add("There is a pot for cooking here.")
					elseif map[self.x][self.y]:get_name() == 'Donation Box' then
						message_add("There is a Donation Box here.")
					elseif map[self.x][self.y]:get_name() == 'KeyStone' then
						message_add("There is a stone with a key slot set into it here.")
					end
					
					
				--- overworld square messages and ambush check
				elseif level.name == 'Overworld' then
					if map[self.x][self.y]:get_char() == 'O' or map[self.x][self.y]:get_char() == '*' then
						for i = 1, # overworld_levels do
							if overworld_levels[i].x == self.x and overworld_levels[i].y == self.y then
								message_add(overworld_levels[i].name)
							end
						end
					elseif map[self.x][self.y]:get_char() == '.' then
						message_add("A road")
					elseif map[self.x][self.y]:get_char() == '&' then
						message_add("A forest")
					elseif map[self.x][self.y]:get_char() == '"' then
						message_add("A field")
					end
					
					if map[self.x][self.y]:get_char() ~= 'O' and map[self.x][self.y]:get_char() ~= ' .' then
						if math.random(1000) <= 10 then
							map_random_overworld_encounter()
							message_add("You've been ambushed while traveling!")
						end
					end
					
				end
				
				
				--- tile item seen messages
				if map[self.x][self.y]:get_items() then
					local items = map[self.x][self.y]:get_items()
					if # items == 1 then
						message_add('You see here a ' .. items[1]:get_pname() .. '.')
					elseif # items == 2 then
						message_add('You see here a couple of objects')
					elseif # items == 3 then
						message_add('You see here a few objects')
					elseif # items == 4 then
						message_add('You see here several objects')
					else
						message_add('You see here many objects')
					end
				end
			end
			
		elseif map[new_x][new_y]:get_holding() and map[new_x][new_y]:get_holding():get_team() ~= self.team then
			Creature.fight(self, new_x, new_y)
			
		elseif self == player and map[new_x][new_y]:get_holding() and map[new_x][new_y]:get_holding():get_team() == self.team and map[new_x][new_y]:get_holding():get_shop() then
			shop_load_items(map[new_x][new_y]:get_holding():get_shop())
			shop_window = true
			shop_load_items()
			
			--- messages for special shopkeepers
			if map[new_x][new_y]:get_holding():get_shop() == 'Aki' then
				message_add("Minoriko Aki offers you some sweet potatos.")
			elseif map[new_x][new_y]:get_holding():get_shop() == 'Rino' then
				message_add("Rinnosuke welcomes you into Kourindou")
			end
			
		elseif self == player and map[new_x][new_y]:get_holding() and map[new_x][new_y]:get_holding():get_team() == self.team and map[new_x][new_y]:get_holding():get_sell() then
			inventory_open = true
			inventory_action = 'sell'			
		end
	
	elseif map[new_x][new_y]:get_block_move() and map[new_x][new_y]:get_name() == "BambooShoot" then
		if player_equipment.hand then
			if player_equipment.hand:get_weptype() == 'axe' then		
				map[new_x][new_y] = Tile:new({name = 'Floor', x = new_x, y = new_y})
				player_fov()
				map_back_canvas_update(new_x, new_y)
				next_turn = true
			end
		end
		
	end
	
end

function Creature:fight(x, y)

	local damage = math.random(self.base_damage[1], self.base_damage[2])
	local mon_name = map[x][y]:get_holding():get_name()
	
	if self == player then
		--- damage from weapons
		if player_equipment.hand then
			damage = damage + player_equipment.hand:get_damage()
			damage = damage + player_mod_get('damage')
		end
		
		--- changes from player skill
		--- fighting skill
		damage = math.floor(damage * (1 + (player_skills.fighting * 0.01)))
		player_skills.fighting = player_skills.fighting + 0.01
		--- weapon skill
		if player_equipment.hand then
			if player_skills[player_equipment.hand:get_weptype()] then
				damage = math.floor(damage * (1.05 * (player_skills[player_equipment.hand:get_weptype()] + 1)))
				player_skills[player_equipment.hand:get_weptype()] = player_skills[player_equipment.hand:get_weptype()] + 0.01
			end
		end
		
		--- changes from player feats
		if player_equipment.hand then
			if player_feat_search(player_equipment.hand:get_weptype()) > 0 then
				damage = math.floor( damage * (player_feat_search(player_equipment.hand:get_weptype())) )
			end
		end
		
		--- changes from player stance
		if player_stance == 1 then
			damage = math.ceil(damage * .30)
		elseif player_stance == 2 then
			damage = math.ceil(damage * .70)
		elseif player_stance == 4 then
			damage = math.ceil(damage * 1.30)
		elseif player_stance == 5 then
			damage = math.ceil(damage * 1.70)
		end
		
		--- critical hits
		local crit = 0
		if player_equipment.hand then crit = player_equipment.hand:get_crit() end
		if math.random(1, 100) <= crit then damage = damage + math.ceil(damage * .15) end
		
		--- fighting costs hunger!
		self.food_tick = self.food_tick - 5
	end
	
	map[x][y]:get_holding():take_dam(damage, 'phys', self.name)

end

function Creature:take_dam(dam, dtype, name)
	
	local armor = self.armor
	
	if self == player then
		--- armor
		if player_equipment.head then armor = armor + player_equipment.head:get_armor() end
		if player_equipment.torso then armor = armor + player_equipment.torso:get_armor() end
		if player_equipment.legs then armor = armor + player_equipment.legs:get_armor() end
		if player_equipment.feet then armor = armor + player_equipment.feet:get_armor() end
		armor = armor + player_mod_get('armor')
		
		--- damage changes due to stances
		if player_stance == 1 then
			dam = math.ceil(dam * .65)
		elseif player_stance == 2 then
			dam = math.ceil(dam * .75)
		elseif player_stance == 4 then
			dam = math.ceil(dam * 1.30)
		elseif player_stance == 5 then
			dam = math.ceil(dam * 1.65)
		end
		
		--- damage reduction from feats
		if player_feat_search('damred') ~= 0 then
			dam = math.ceil( dam * player_feat_search('damred') )
		end
		
		--- dodge
		if player_stance == 1 and dtype == 'phys' then
			if math.random(1, 100) <= 20 then
				dam = 0
				player_skills.evasion = player_skills.evasion + 0.01
			end		
		end
		
		--- evasion
		local evasion = player_skills.evasion + self.evasion
		if math.random(1, 100) <= player_skills.evasion + 1 * 2 and dtype == 'phys' then
			dam = 0
			player_skills.evasion = player_skills.evasion + 0.01
		end
		
		--- graze
		if dtype == 'danmaku' then
			if player_stance == 1 then
				dam = 0
			elseif player_stance == 2 then
				if math.random(1, 100) <= 50 then
					dam = 0
				end
			elseif player_stance == 3 then
				if math.random(1, 100) <= 25 then
					dam = 0
				end
			elseif player_stance == 4 then
				if math.random(1, 100) <= 5 then
					dam = 0
				end
			end
		end
		
	end
	
	--- enemy evasion
	if math.random(1, 100) <= self.evasion then
		dam = 0
	end
	
	local dam_red = ((0.06 * armor) / (1 + 0.06 * armor)) * 100
	if dam_red ~= 0 then 
		dam_red = dam_red / 100
		dam = math.floor(dam - (dam * dam_red))
	end
	self.hp_cur = self.hp_cur - dam
	
	if dam > 0 then
		if self == player then
			message_add("You were hit by the " .. name .. " for " .. dam .. " damage.")
		else
			message_add("You hit the " .. self.name .. " for " .. dam .. " damage.")
		end
	elseif dam == 0 and dtype == 'phys' then
		if self == player then
			message_add("You dodged the attack from the " .. name .. ".")
		else
			message_add("The " .. self.name .. " dodged your attack.")
		end
	elseif dam == 0 and dtype == 'danmaku' then
		if self == player then
			message_add("You grazed the danmaku fired from the " .. name .. ".")
		else
			message_add("The " .. self.name .. " grazed your danmaku.")
		end
	end
	
	if self.hp_cur < 1 then
		if self ~= player then 
			message_add("You killed the " .. self.name .. ".") 
			monster_corpse_check(self)
		else
			--- player dead, delete all save files
			player_dead = true
			message_add("You die...")
			local files = love.filesystem.enumerate("")
			for k, file in ipairs(files) do	
				love.filesystem.remove(file)
			end
		end
		map[self.x][self.y]:set_holding(nil)
		player_exp = player_exp + self.exp
	end

end

function Creature:heal(amnt)

	self.hp_cur = self.hp_cur + amnt
	if self.hp_cur > self.hp_max then
		self.hp_cur = self.hp_max 
	end
	
end

function Creature:mheal(amnt)

	self.mana_cur = self.mana_cur + amnt
	if self.mana_cur > self.mana_max then
		self.mana_cur = self.mana_max 
	end
	
end

function Creature:lose_mana(amnt)

	self.mana_cur = self.mana_cur - amnt
	if self.mana_cur < 0 then
		self.mana_cur = 0
	end
	
end

function Creature:get_armor()

	local armor = self.armor
	if self == player then
		if player_equipment.head then armor = armor + player_equipment.head:get_armor() end
		if player_equipment.torso then armor = armor + player_equipment.torso:get_armor() end
		if player_equipment.legs then armor = armor + player_equipment.legs:get_armor() end
		if player_equipment.feet then armor = armor + player_equipment.feet:get_armor() end
		armor = armor + player_mod_get('armor')
	end
	return armor

end

function Creature:get_evasion()

	local evasion = self.evasion
	if self == player then
		if player_equipment.head then evasion = evasion + player_equipment.head:get_evasion() end
		if player_equipment.torso then evasion = evasion + player_equipment.torso:get_evasion() end
		if player_equipment.legs then evasion = evasion + player_equipment.legs:get_evasion() end
		if player_equipment.feet then evasion = evasion + player_equipment.feet:get_evasion() end
		evasion = evasion + player_mod_get('evasion')
	end
	return evasion
	
end

function Creature:draw_ascii(x, y)

	if map[x][y]:get_lit() then
		self.color()
		love.graphics.print(self.char, ascii_draw_point(x), ascii_draw_point(y))
		love.graphics.setColor(255, 255, 255, 255)
	end
	
end	

function Creature:set_x(num) self.x = num end
function Creature:set_y(num) self.y = num end
function Creature:set_turn_cd(num) self.turn_cd = num end
function Creature:set_hp_max(amnt) self.hp_max = amnt end
function Creature:set_hp_cur(amnt) self.hp_cur = amnt end
function Creature:set_mana_max(amnt) self.mana_max = amnt end
function Creature:set_mana_cur(amnt) self.mana_cur = amnt end

function Creature:get_team() return self.team end
function Creature:get_name() return self.name end
function Creature:get_turn_cd() return self.turn_cd end
function Creature:get_speed() return self.speed end
function Creature:get_x() return self.x end
function Creature:get_y() return self.y end
function Creature:get_hp_cur() return self.hp_cur end
function Creature:get_hp_max() return self.hp_max end
function Creature:get_mana_cur() return self.mana_cur end
function Creature:get_mana_max() return self.mana_max end
function Creature:get_base_damage() return self.base_damage end
function Creature:get_shop() return self.shop end
function Creature:get_sell() return self.sell end
function Creature:get_unique() return self.unique end
function Creature:get_char() return self.char end
function Creature:get_corpse() return self.corpse end
	
Item = Class('Item')
function Item:initialize(arg)

	self.name = arg.name or 'piece of junk'
	self.pname = arg.pname or self.name
	self.quaffable = arg.quaffable or false
	self.potion = arg.potion or false
	self.scroll = arg.scroll or false
	self.read = arg.reads or false
	self.readable = arg.readable or false
	self.edible = arg.edible or false
	self.cook = arg.cook or false
	self.nutrition = arg.nutrition or false
	self.wearable = arg.wearable or false
	self.slot = arg.slot or false
	self.armor = arg.armor or 0
	self.evasion = arg.evasion or 0
	self.damage = arg.damage or 5
	self.weptype = arg.weptype or "DNE"
	self.crit = arg.crit or 0
	self.bullet = arg.bullet or 0
	self.weight = arg.weight or 3
	self.quaff = arg.quaff or false
	self.affect = arg.affect or function () end
	self.apply = arg.apply or false
	self.afunc = arg.afunc or function () end
	self.message = arg.message or "DNE"
	self.char = arg.char or ' ;'
	self.gold = arg.gold or false
	self.corpse = self.corpse or false
	self.color = arg.color or function () love.graphics.setColor(186, 140, 93, 255) end
	if arg.self then self = arg.self end
	
end

function Item:draw(x, y)

	self.color()
	love.graphics.print(self.char, ascii_draw_point(x), ascii_draw_point(y))
	love.graphics.setColor(255, 255, 255, 255)
	
end

function Item:get_pname() 
	
	if self.potion then
		local known = false
		for i = 1, # known_potions do
			if known_potions[i] == self.name then
				known = true
			end
		end
		
		if known then return self.name end
		if not known then return self.pname end		
		
	elseif self.scroll then
		local known = false
		for i = 1, # known_scrolls do
			if known_scrolls[i] == self.name then
				known = true
			end
		end
		
		if known then return self.name end
		if not known then return self.pname end
		
	elseif self.gold then
		if self.gold == 1 then return "1 gold piece" end
		if self.gold > 1 then return self.gold .. " gold pieces" end
		
	end
	
	return self.pname
	
end

function Item:get_name() return self.name end
function Item:get_pname_real() return self.pname end
function Item:get_slot() return self.slot end
function Item:get_armor() return self.armor end
function Item:get_evasion() return self.evasion end
function Item:get_damage() return self.damage end
function Item:get_crit() return self.crit end
function Item:get_quaff() return self.quaff end
function Item:get_affect() return self.affect end
function Item:get_cook() return self.cook end
function Item:get_edible() return self.edible end
function Item:get_nutrition() return self.nutrition end
function Item:get_message() return self.message end
function Item:get_gold() return self.gold end
function Item:get_read() return self.read end
function Item:get_scroll() return self.scroll end
function Item:get_apply() return self.apply end
function Item:get_afunc() return self.afunc end
function Item:get_bullet() return self.bullet end
function Item:get_weptype() return self.weptype end
function Item:get_weight() return self.weight end
function Item:get_char() return self.char end
function Item:get_corpse() return self.corpse end
	
Tile = Class('Tile')
function Tile:initialize(arg)

	self.name = arg.name or 'Wall'
	self.holding = arg.holding or nil
	self.block_move = arg.block_move or false
	self.block_sight = arg.block_sight or false
	self.char = arg.char or '#'
	self.seen = arg.seen or false
	self.lit = arg.lit or false
	self.x = arg.x or 1
	self.y = arg.y or 1
	self.items = arg.items or nil
	self.color = arg.color or {r=255, g=255, b=255}
	
	if self.name == 'Floor' then
		self.char = ' .'
		self.block_move = false
		self.block_sight = false
	elseif self.name == 'Wall' then
		self.char = '#'
		self.block_move = true
		self.block_sight = true
	elseif self.name == 'Tree' then
		self.char = 'T'
		self.block_move = true
		self.block_sight = true
		self.color = {r=0, g=255, b=0}
	elseif self.name == 'Water' then
		self.char = '~'
		self.block_move = false
		self.block_sight = false
		self.color = {r=133, g=249, b=255}
	elseif self.name == 'DStairs' then
		self.char = '>' 
		self.block_move = false
		self.block_sight = false
	elseif self.name == 'UStairs' then
		self.char = '<' 
		self.block_move = false
		self.block_sight = false
	elseif self.name == 'SpaceFloor' then
		self.char = ' .'
		self.block_move = false
		self.block_sight = false
	end
end

function Tile:draw_ascii()

	love.graphics.setColor(self.color.r, self.color.g, self.color.b, 255)
	love.graphics.print(self.char, ascii_draw_point(self.x), ascii_draw_point(self.y))
	love.graphics.setColor(255, 255, 255, 255)
		
end

function Tile:draw_holding()

	self.holding:draw_ascii(self.x, self.y)

end

function Tile:set_holding(foo) self.holding = foo end
function Tile:set_items(foo) self.items = foo end
function Tile:set_seen() self.seen = true end
function Tile:set_lit() self.lit = true end
function Tile:set_unlit() self.lit = false end
function Tile:set_self(slf) self = slf end

function Tile:get_holding() return self.holding end
function Tile:get_block_move() return self.block_move end
function Tile:get_block_sight() return self.block_sight end
function Tile:get_lit() return self.lit end
function Tile:get_seen() return self.seen end
function Tile:get_name() return self.name end
function Tile:get_items() return self.items end
function Tile:get_char() return self.char end
function Tile:get_color() return self.color end
function Tile:get_self() return self end

function ascii_draw_point(num)

	num = (num - 1) * char_width
	return num

end

function distance(x1, y1, x2, y2)

	local distance = math.sqrt( ((x2 - x1)^2) + ((y2 - y1)^2) )
	return distance

end

function map_setup(width, height)
	
	map = {}
	for x = 1, width do
		map[x] = {}
		for y = 1, height do
			map[x][y] = Tile:new({name = 'Wall', x = x, y = y})
		end
	end
	
end

function load_coords_map()

	map_setup(map_width, map_height)

	for i = 1, # overworld_levels do
		print(overworld_levels[i].name)
		if level.name == overworld_levels[i].name then
			level.depth = level.depth - 1
			overworld_levels[i].func('down')
			map[player:get_x()][player:get_y()]:set_holding(nil)
			map_new_place_player(player_coords.x, player_coords.y)
			return
		end
	end
	
	--- default, in case we couldn't find the real load location
	map_hakurei_shrine('up')
	map_back_canvas_draw()

end

function load_hp_mana()

	player:set_hp_max(player_hp_mana.hp_max)
	player:set_hp_cur(player_hp_mana.hp_cur)
	player:set_mana_max(player_hp_mana.mana_max)
	player:set_mana_cur(player_hp_mana.mana_cur)

end

function load_feats()

	for i = 1, # player_feats_load do
		for k = 1, # player_feats do
			if player_feats_load[i] == player_feats[k].name then
				player_feats[k].have = true
			end
		end
	end

end

function setup_character()

	for i = 1, # game_characters do 
		if game_characters[i].name == choice then
			player = Creature:new(game_characters[i].stats)
			player_name = game_characters[i].name
			player_stats = game_characters[i].player_stats
			player_spells = game_characters[i].starting_spells
			player_spells_learn = game_characters[i].player_spells_learn
			player_feats_load = {}
			player_hp_mana = {hp_max = game_characters[i].stats.hp_max, hp_cur = game_characters[i].stats.hp_max, mana_max = game_characters[i].stats.mana_max, mana_cur = game_characters[i].stats.mana_max}
			player_coords = { x = player:get_x(), y = player:get_y() }
			--- if a player file exists then load it!
			load_player()
			load_feats()
			load_hp_mana()
			load_coords_map()
		end
	end

end

function starting_inventory()

	player_inventory = { {item = Item:new(game_items[# game_items]), quantity = 1} }
	player_equipment.torso = shop_find_game_item('Sarashi')
	player_equipment.hand = shop_find_game_item('Big Stick')
	
end

