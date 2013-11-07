--- game files
require("map")
require("items")
require("monsters")
require("characters")

map = {}
map_width = 46
map_height = 33
map_canvas = love.graphics.newCanvas(800, 600)
map_back_canvas = love.graphics.newCanvas(800, 600)

char_width = 14

player = {}
player_level = 1
player_exp = 0
player_gold = 1000
player_food = {level = 500, cap = 1000, hungry = 300, starving = 100, weak = 25}
player_name = 'Reimu Hakurei'
player_stats = { str = 6,
				 dex = 9,
				 int = 5,
				 con = 7,}
	
player_skills = { fighting = 0, cooking = 0 }
	
player_spells = {	{name = 'Omamori of Health', mp_cost = 75, func = function () player:heal(35) end},
					{name = 'Ofuda of Protection', mp_cost = 50, func = function () add_modifier({name = 'Protection', turn = 60, armor = 5}) end},
				}
player_spells_learn = {}
spells_open = false

player_mods = {}

player_inventory = {}
inventory_open = false
inventory_action = false
inventory_to_drop = {}

danmaku_dir = false
danmaku = false

shop_window = false
shop_items = { }

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

function game:enter()
		
	setup_character()
	map_hakurei_shrine('up')
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
	
	--- danmaku draw
	if danmaku then
		love.graphics.setColor(0, 100, 255, 255)
		love.graphics.print('*', ascii_draw_point(danmaku.x), ascii_draw_point(danmaku.y))
		love.graphics.setColor(255, 255, 255, 255)
	end
	
end

function game:keypressed(key)

	if player:get_turn_cd() <= 1 and not danmaku then
		if not inventory_open and not pickup_many_items and not spells_open and not shop_window and not danmaku_dir then
			if key == 'kp8' then player:move(0, -1) next_turn = true end
			if key == 'kp2' then player:move(0, 1) next_turn = true end
			if key == 'kp4' then player:move(-1, 0) next_turn = true end
			if key == 'kp6' then player:move(1, 0) next_turn = true end
			if key == 'kp7' then player:move(-1, -1) next_turn = true end
			if key == 'kp9' then player:move(1, -1) next_turn = true end
			if key == 'kp1' then player:move(-1, 1) next_turn = true end
			if key == 'kp3' then player:move(1, 1) next_turn = true end
			
			if key == 'kp5' then next_turn = true end
			
			if level.name ~= 'Overworld' then
				if key == 'g' then pickup_item() next_turn = true end
				if key == 'i' then inventory_open = true inventory_action = 'look' end
				if key == 'd' then inventory_open = true inventory_action = 'drop' inventory_to_drop = {} end
				if key == 'w' then inventory_open = true inventory_action = 'wield' end
				if key == 'p' then inventory_open = true inventory_action = 'wear' end
				if key == 't' then inventory_open = true inventory_action = 'remove' end
				if key == 'q' then inventory_open = true inventory_action = 'quaff' end
				if key == 'e' then inventory_open = true inventory_action = 'eat' end
				if key == 'r' then inventory_open = true inventory_action = 'read' end
				if key == 'a' then inventory_open = true inventory_action = 'apply' end
				
				if key == 'c' then spells_open = true end
				if key == 'u' then map_use_tile() end	

				if key == 'f' then danmaku_dir = true message_add("Fire danmaku in which direction?") end
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
			
		elseif danmaku_dir then
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

	turn_machine()	
	stair_cd = stair_cd - 1
	
	if player:get_turn_cd() <= 1 and stair_cd <= 1 then
		--- up and down stairs in levels
		if (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and love.keyboard.isDown('.') and map[player:get_x()][player:get_y()]:get_name() == 'DStairs' then stair_machine('down') end
		if (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and love.keyboard.isDown(',') and map[player:get_x()][player:get_y()]:get_name() == 'UStairs'  then stair_machine('up') end
		--- down for the overworld
		if (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) and love.keyboard.isDown('.') and level.name == 'Overworld' then overworld_down() end
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

function danmaku_fire(dx, dy)

	message_add("You fired danmaku!")

	local air = true
	local x = player:get_x()
	local y = player:get_y()
	repeat
	
		x = x + dx
		y = y + dy
		
		if map[x][y]:get_block_move() then air = false end
		if map[x][y]:get_holding() then 
			air = false 
			local dam = math.random(player_stats.int * 4, player_stats.int * 5)
			map[x][y]:get_holding():take_dam(dam, 'phys', 'whut')
		end
	
	until not air
	
	danmaku = {x = player:get_x(), y = player:get_y(), dx = dx, dy = dy, ex = x, ey = y, cd = 3}

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
			elseif player_food.level < 1000 then text = text .. "  You feel bloated." end
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

	if key  == 'return' or key == 'kpenter' then	
		--- add items to player inventory
		for i = 1, # alphabet do
			if pickup_many_items_choice[alphabet[i]] and items_sorted[i] then
				for k = 1, items_sorted[i].quantity do
					add_item_to_inventory(items_sorted[i].item)
					items_sorted[i].quantity = items_sorted[i].quantity - 1
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
			add_item_to_inventory(map[player:get_x()][player:get_y()]:get_items()[1])
			message_add('You picked up the ' .. map[player:get_x()][player:get_y()]:get_items()[1]:get_pname() .. '.')
			map[player:get_x()][player:get_y()]:set_items(nil)
			pickuped = true
		else
			pickup_many_items = true
			pickup_many_items_choice = {}			
		end	
		
	end
	return pickuped

end

function add_item_to_inventory(item)

	if item:get_gold() then
		player_gold = player_gold + item:get_gold()
		return
	end

	if # player_inventory == 0 then
		table.insert(player_inventory, {item = item, quantity = 1})
	else
		local similar = false
		for i = 1, # player_inventory do
			if player_inventory[i].item:get_name() == item:get_name() then
				player_inventory[i].quantity = player_inventory[i].quantity + 1
				similar = true
			end
		end
		if not similar then
			table.insert(player_inventory, {item = item, quantity = 1})
		end
	end
				
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

	if next_turn then
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

	for x = 1, map_width do
		for y = 1, map_height do
			if map[x][y]:get_holding() then
				map[x][y]:get_holding():ai_take_turn()
			end
		end
	end

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
	
	love.filesystem.write(level.name .. "_" .. level.depth .. ".lua", text)
	
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
	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x, start_y, width, height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('line', start_x+2, start_y+2, width-2, height-2)
	
	love.graphics.print(player_name, start_x + 10, start_y + 10)
	love.graphics.print("Level: " .. player_level, start_x + 10, start_y + 25)
	love.graphics.print("XP: " .. player_exp, start_x + 10, start_y + 40)
	
	love.graphics.print("STR: " .. player_stats.str, start_x + 10, start_y + 65)
	love.graphics.print("DEX: " .. player_stats.dex, start_x + 10, start_y + 80)
	love.graphics.print("INT: " .. player_stats.int, start_x + 10, start_y + 95)
	love.graphics.print("CON: " .. player_stats.con, start_x + 10, start_y + 110)
	
	love.graphics.print("Armor: " .. player:get_armor(), start_x + 10, start_y + 140)
	
	love.graphics.print("HP:" .. player:get_hp_cur() .. "/" .. player:get_hp_max(), start_x + 10, start_y + 170)
	love.graphics.print("MP:" .. player:get_mana_cur() .. "/" .. player:get_mana_max(), start_x + 10, start_y + 185)
	
	if player_food.level <= player_food.hungry and player_food.level > player_food.starving then
		love.graphics.print('Hungry', start_x + 10, start_y + 200)
	elseif player_food.level <= player_food.starving and player_food.level > player_food.weak then
		love.graphics.print('Starving', start_x + 10, start_y + 200)
	elseif player_food.level <= player_food.weak then
		love.graphics.print('Weak', start_x + 10, start_y + 200)
	end
	
	for i = 1, # player_mods do
		love.graphics.print(player_mods[i].name, start_x + 10, start_y + 215 + ((i - 1) * 15))
	end
	
	love.graphics.print("Gold: " .. player_gold, start_x + 10, start_y + 400)
	love.graphics.print(level.name, start_x + 10, start_y + 430)
	love.graphics.print("Depth: " .. level.depth, start_x + 10, start_y + 445)
	
end

function draw_inventory()

	local start_x = 0
	local start_y = 0
	local width = 300
	local height = (# player_inventory + 2) * 15 + 8
	
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x, start_y, width, height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('line', start_x+2, start_y+2, width-2, height-2)
	
	if inventory_action == 'look' then
		love.graphics.print("Inventory", start_x + 24, start_y + 4)
		love.graphics.print("Press any key to continue...", start_x + 24, start_y + ((# player_inventory) + 1) * 15 + 4)
	elseif inventory_action == 'drop' then
		love.graphics.print("Drop what?", start_x + 24, start_y + 4)
		love.graphics.print("Press ENTER to drop marked items...", start_x + 24, start_y + ((# player_inventory) + 1) * 15 + 4)
	elseif inventory_action == 'wield' then
		love.graphics.print("Wield what?", start_x + 24, start_y + 4)
		love.graphics.print("ENTER for empty hands, ESC to cancel", start_x + 24, start_y + ((# player_inventory) + 1) * 15 + 4)
	elseif inventory_action == 'wear' then
		love.graphics.print("Wear what?", start_x + 24, start_y + 4)
		love.graphics.print("Choose what to wear, ESC to cancel", start_x + 24, start_y + ((# player_inventory) + 1) * 15 + 4)
	elseif inventory_action == 'remove' then
		love.graphics.print("Remove what?", start_x + 24, start_y + 4)
		love.graphics.print("Choose what to remove, ESC to cancel", start_x + 24, start_y + ((# player_inventory) + 1) * 15 + 4)
	elseif inventory_action == 'quaff' then
		love.graphics.print("Quaff what?", start_x + 24, start_y + 4)
		love.graphics.print("Choose what to quaff, ESC to cancel", start_x + 24, start_y + ((# player_inventory) + 1) * 15 + 4)
	elseif inventory_action == 'cook' then
		love.graphics.print("Cook what?", start_x + 24, start_y + 4)
		love.graphics.print("Choose what to cook, ESC to cancel", start_x + 24, start_y + ((# player_inventory) + 1) * 15 + 4)
	elseif inventory_action == 'eat' then
		love.graphics.print("Eat what?", start_x + 24, start_y + 4)
		love.graphics.print("Choose what to eat, ESC to cancel", start_x + 24, start_y + ((# player_inventory) + 1) * 15 + 4)
	elseif inventory_action == 'sell' then
		love.graphics.print("Sell what?", start_x + 24, start_y + 4)
		love.graphics.print("Choose what to sell, ESC to cancel", start_x + 24, start_y + ((# player_inventory) + 1) * 15 + 4)
	elseif inventory_action == 'read' then
		love.graphics.print("Read what?", start_x + 24, start_y + 4)
		love.graphics.print("Choose what to read, ESC to cancel", start_x + 24, start_y + ((# player_inventory) + 1) * 15 + 4)
	elseif inventory_action == 'apply' then
		love.graphics.print("Apply what?", start_x + 24, start_y + 4)
		love.graphics.print("Choose what to apply, ESC to cancel", start_x + 24, start_y + ((# player_inventory) + 1) * 15 + 4)
	end
	
	local message = ""
	
	--- inventory 
	for i = 1, # player_inventory do
	
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
		
		love.graphics.print(message, start_x + 4, start_y + (i) * 15 + 4)
	end
	
	--- equipment
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', start_x + width + start_x, start_y, width, 8 * 15 + 8)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle('line', start_x+2 + width + start_x, start_y+2, width-2, 8 * 15 + 8 - 2)
	
	love.graphics.print("Equipment", start_x + width + start_x + 24, start_y + 4)
	love.graphics.print("---Armor---", start_x + width + start_x + 24, start_y + 15 + 4)
	
	if inventory_action == 'remove' then message = 'a: ' 
		else message = "Head: " end
	if player_equipment.head then message = message .. player_equipment.head:get_pname() end
	love.graphics.print(message, start_x + width + start_x + 4, start_y + 30 + 4)
	
	if inventory_action == 'remove' then message = 'b: ' 
		else message = "Body: " end
	if player_equipment.torso then message = message .. player_equipment.torso:get_pname() end
	love.graphics.print(message, start_x + width + start_x + 4, start_y + 45 + 4)
	
	if inventory_action == 'remove' then message = 'c: ' 
		else message = "Legs: " end
	if player_equipment.legs then message = message .. player_equipment.legs:get_pname() end
	love.graphics.print(message, start_x + width + start_x + 4, start_y + 60 + 4)
	
	if inventory_action == 'remove' then message = 'd: ' 
		else message = "Feet: " end
	if player_equipment.feet then message = message .. player_equipment.feet:get_pname() end
	love.graphics.print(message, start_x + width + start_x + 4, start_y + 75 + 4)
	
	love.graphics.print("---Weapon---", start_x + width + start_x + 24, start_y + 90 + 4)
	
	if inventory_action == 'remove' then message = 'e: ' 
		else message = "Hands: " end
	if player_equipment.hand then message = message .. player_equipment.hand:get_pname() end
	love.graphics.print(message, start_x + width + start_x + 4, start_y + 105 + 4)

end

function player_fov()

	if level.name ~= 'Overworld' then map_calc_fov(player:get_x(), player:get_y(), world_see_distance)		
	elseif level.name == 'Overworld' then map_overworld_fov(player:get_x(), player:get_y(), 2) end
	
end

function shop_load_items(shop)

	if shop == 'Weapon' then
		shop_items = {	{ name = 'Broom', cost = 25, item = Item:new(game_items[18]) },
						{ name = 'Gohei Stick', cost = 45, item = Item:new(game_items[21]) },
						{ name = 'Dagger', cost = 125, item = Item:new(game_items[26]) },
						{ name = 'Katana', cost = 250, item = Item:new(game_items[13]) },
						}
	elseif shop == 'Armor' then
		shop_items = {	{ name = 'Leather Vest', cost = 50, item = Item:new(game_items[25]) },
						{ name = 'Cloth Skirt', cost = 75, item = Item:new(game_items[19]) },
						{ name = 'Leahter Shoes', cost = 75, item = Item:new(game_items[10]) },
						{ name = 'Silk Bonnet', cost = 85, item = Item:new(game_items[13]) },
						}
	elseif shop == 'Potion' then
		shop_items = {	{ name = 'Potion of Gain', cost = 350, item = Item:new(game_items[14]) },
						{ name = 'Potion of Healing', cost = 50, item = Item:new(game_items[22]) },
						}
	end
	
end

Creature = Class('Creature')
function Creature:initialize(arg)

	self.name = arg.name or 'Monster'
	self.hp_max = arg.hp_max or 125
	self.hp_cur = arg.hp_cur or self.hp_max
	self.hp_regen = arg.hp_regen or 125
	self.hp_regen_timer = arg.hp_regen_timer or self.hp_regen
	self.mana_max = arg.mana_max or 100
	self.mana_cur = arg.mana_cur or self.mana_max
	self.mana_regen = arg.mana_regen or 25
	self.mana_regen_timer = arg.mana_regen_timer or self.mana_regen
	self.food_tick = 25
	self.base_damage = arg.base_damage or {15, 25}
	self.armor = arg.armor or 1
	self.speed = arg.speed or 10
	self.shop = arg.shop or false
	self.sell = arg.sell or false
	self.turn_cd = arg.turn_cd or 0
	self.x = arg.x or 1
	self.y = arg.y or 1
	self.team = arg.team or 1
	self.char = arg.char or 'M'
	self.ai = arg.ai or 'normal'
	self.seen_player = arg.seen_player or false
	self.seen_player_cd = 10
	self.exp = arg.exp or 10
	self.unique = arg.unique or false
	self.color = arg.color or function () love.graphics.setColor(255, 255, 255, 255) end
	
end

function Creature:ai_take_turn()

	self.turn_cd = self.turn_cd - 1
	self.hp_regen_timer = self.hp_regen_timer - 1
	self.mana_regen_timer = self.mana_regen_timer - 1
	self.food_tick = self.food_tick - 1
	if self.turn_cd < 1 then
		self.turn_cd = self.speed
		if self == player then self.turn_cd = self.speed - player_stats.dex - player_mod_get('speed') end
		if self.name ~= "Player" then
			if self.ai == 'wander' then
				Creature.ai_wander(self)
			elseif self.ai == 'normal' then
				Creature.ai_normal(self)
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

end

function Creature:levelup()

	if player_exp >= player_level^5 + 200 then
	
		player_exp = 0
		player_level = player_level + 1
		
		self.hp_max = self.hp_max + player_stats.con * 5
		self.mana_max = self.mana_max + player_stats.int * 5
		self.base_damage[1] = self.base_damage[1] + player_stats.str * 3
		self.base_damage[2] = self.base_damage[2] + player_stats.str * 3
		
		for i = 1, # player_spells_learn do
			if player_spells_learn[i].level == player_level then
				table.insert(player_spells, player_spells_learn[i])
				table.remove(player_spells_learn, i)
				break
			end
		end
		
	end

end

function Creature:ai_wander()

	local dx = math.random(-1, 1)
	local dy = math.random(-1, 1)
	Creature.move(self, dx, dy)

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
		
		if path_to_player[self.x-1][self.y] < path_to_player[self.x][self.y] and not moved then Creature.move(self, -1, 0) moved = true end
		if path_to_player[self.x+1][self.y] < path_to_player[self.x][self.y] and not moved then Creature.move(self, 1, 0) moved = true end
		if path_to_player[self.x][self.y-1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, 0, -1) moved = true end
		if path_to_player[self.x][self.y+1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, 0, 1) moved = true end
		if path_to_player[self.x-1][self.y-1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, -1, -1) moved = true end
		if path_to_player[self.x-1][self.y+1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, -1, 1) moved = true end
		if path_to_player[self.x+1][self.y-1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, 1, -1) moved = true end
		if path_to_player[self.x+1][self.y+1] < path_to_player[self.x][self.y] and not moved then Creature.move(self, 1, 1) moved = true end
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
					end
				--- overworld square messages
				elseif level.name == 'Overworld' then
					if map[self.x][self.y]:get_char() == 'O' or map[self.x][self.y]:get_char() == '*' then
						for i = 1, # overworld_levels do
							if overworld_levels[i].x == self.x and overworld_levels[i].y == self.y then
								message_add("You are at " .. overworld_levels[i].name)
							end
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
		elseif self == player and map[new_x][new_y]:get_holding() and map[new_x][new_y]:get_holding():get_team() == self.team and map[new_x][new_y]:get_holding():get_sell() then
			inventory_open = true
			inventory_action = 'sell'
		end
	end
	
end

function Creature:fight(x, y)

	local damage = math.random(self.base_damage[1], self.base_damage[2])
	local mon_name = map[x][y]:get_holding():get_name()
	
	if self == player then
		if player_equipment.hand then
			damage = damage + player_equipment.hand:get_damage()
			damage = damage + player_mod_get('damage')
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
		if player_equipment.head then armor = armor + player_equipment.head:get_armor() end
		if player_equipment.torso then armor = armor + player_equipment.torso:get_armor() end
		if player_equipment.legs then armor = armor + player_equipment.legs:get_armor() end
		if player_equipment.feet then armor = armor + player_equipment.feet:get_armor() end
		armor = armor + player_mod_get('armor')
	end
	
	local dam_red = ((0.06 * armor) / (1 + 0.06 * armor)) * 100
	if dam_red ~= 0 then 
		dam_red = dam_red / 100
		dam = math.floor(dam - (dam * dam_red))
	end
	self.hp_cur = self.hp_cur - dam
	
	if self == player then
		message_add("You were hit by the " .. name .. " for " .. dam .. " damage.")
	else
		message_add("You hit the " .. self.name .. " for " .. dam .. " damage.")
	end
	
	if self.hp_cur < 1 then
		if self ~= player then message_add("You killed the " .. self.name .. ".") end
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

function Creature:draw_ascii(x, y)

	if map[x][y]:get_lit() then
		self.color()
		love.graphics.print(self.char, ascii_draw_point(x), ascii_draw_point(y))
		love.graphics.setColor(255, 255, 255, 255)
	end
	
end	

function Creature:set_x(num) self.x = num end
function Creature:set_y(num) self.y = num end

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
	self.damage = arg.damage or 5
	self.crit = arg.crit or 0
	self.weight = arg.weight or 3
	self.quaff = arg.quaff or false
	self.affect = arg.affect or function () end
	self.apply = arg.apply or false
	self.afunc = arg.afunc or function () end
	self.message = arg.message or "DNE"
	self.char = arg.char or ' ;'
	self.gold = arg.gold or false
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
		if not known then return 'Unknown Potion' end		
		
	elseif self.scroll then
		local known = false
		for i = 1, # known_scrolls do
			if known_scrolls[i] == self.name then
				known = true
			end
		end
		
		if known then return self.name end
		if not known then return 'Unknown Scroll' end
	end
	
	return self.name
	
end

function Item:get_name() return self.name end
function Item:get_pname_real() return self.pname end
function Item:get_slot() return self.slot end
function Item:get_armor() return self.armor end
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

function map_setup(width, height)
	
	map = {}
	for x = 1, width do
		map[x] = {}
		for y = 1, height do
			map[x][y] = Tile:new({name = 'Wall', x = x, y = y})
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
			--- if a player file exists then load it!
			load_player()
		end
	end

end

