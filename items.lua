game_items = {	--- items never randomly generated
				{name = 'Ruined Loaf of Bread', edible = true, cook = false, nutrition = 35, char = '%', prob = 0},
				{name = 'Ruined Rice Ball', edible = true, cook = false, nutrition = 5, char = '%', prob = 0},
				{name = 'Ruined Fish', edible = true, cook = false, nutrition = 15, char = '%', prob = 0},
				{name = 'Cooked Loaf of Bread', edible = true, cook = false, nutrition = 200, char = '%', prob = 0},
				{name = 'Cooked Rice Ball', edible = true, weight = 1, cook = false, nutrition = 150, char = '%', prob = 0},
				{name = 'Cooked Fish', edible = true, cook = false, nutrition = 175, char = '%', prob = 0},
				{name = 'Magic Mirror', apply = true, weight = 5, char = '(', color = function () love.graphics.setColor(232, 216, 227, 255) end, message = "You gaze into the mirror.", afunc = function () level_connection['down'] = function (dir) map_hakurei_shrine('up') end next_level('down') end, prob = 0},
				{name = 'Yin-Yang Orb', slot = 'hand', weptype = 'shinto', color = function () love.graphics.setColor(255, 255, 255, 255) end, weight = 5, crit = 15, damage = 25, char = ')', prob = 0},
				{name = 'Sweet Potato', edible = true, weight = 2, cook = false, nutrition = 175, char = '%', prob = 0},
				{name = 'Police Baton', slot = 'hand', weptype = 'stick', color = function () love.graphics.setColor(150, 150, 150, 255) end, weight = 3, damage = 30, char = ')', prob = 0},
				{name = 'Bullet-Proof Vest', slot = 'torso', weight = 15, color = function () love.graphics.setColor(150, 150, 150, 255) end, armor = 5, char = ']', prob = 0},
				{name = 'Game Boy', apply = true, color = function () love.graphics.setColor(129, 224, 235) end, afunc = function () end, weight = 0, message = "You activate the doomsday device...", char = '(', prob = 0},
				{name = 'Purification Rod', slot = 'hand', weptype = 'shinto', color = function () love.graphics.setColor(212, 235, 87, 255) end, weight = 4, damage = 15, char = ')', prob = 0, bullet = 1},
				{name = 'Hatchet', slot = 'hand', weptype = 'axe', weight = 8, damage = 5, char = ')', prob = 0},
				{name = 'Glasses', slot = 'head', armor = 1, char = '[', color = function () love.graphics.setColor(255, 255, 255, 255) end, prob = 0},
				{name = 'Ceremonial Sword', slot = 'hand', damage = 20, char = ')', color = function () love.graphics.setColor(255, 255, 255, 255) end, prob = 0},
				--- corpses
				{name = 'Fairy Corpse', edible = true, nutrition = 10, corpse = 'fairy', color = function () love.graphics.setColor(87, 185, 235, 255) end, weight = 25, char = '%', prob = 0},
				{name = 'Bug Corpse', edible = true, nutrition = 5, corpse = 'bug', weight = 2, char = '%', prob = 0},
				{name = 'Oni Corpse', edible = true, nutrition = 25, corpse = 'oni', color = function () love.graphics.setColor(255, 0, 0, 255) end, weight = 30, char = '%', prob = 0},
				{name = 'Rabbit Corpse', edible = true, nutrition = 25, corpse = 'rabbit', color = function () love.graphics.setColor(255, 255, 255, 255) end, weight = 15, char = '%', prob = 0},
				--- items randomly generated
				{name = 'Potion of Cure Mutation', quaff = true, potion = true, char = '!', prob = 5, pname = 'Unknown Golden Potion', affect = function () cure_mutation() end, message = "You feel more in touch with the human world."},
				{name = 'Ninja Tabi', slot = 'feet', armor = 1, color = function () love.graphics.setColor(25, 25, 25, 255) end, weight = 0, char = '[', prob = 15, evasion = 2},
				{name = 'Miko Outfit', slot = 'torso', armor = 2, color = function () love.graphics.setColor(255, 0, 0, 255) end, weight = 5, char = ']', prob = 20},				
				{name = 'Scroll of Magic Mapping', reads = true, scroll = true, pname = 'Unknown Scroll', char = '?', prob = 29, affect = function() for x = 1, map_width do for y = 1, map_height do map[x][y]:set_seen() end end end, message = "An image of the surrounding area forms in your mind."},
				{name = 'Silk Dress', slot = 'legs', armor = 3, weight = 6, color = function () love.graphics.setColor(255, 140, 198, 255) end, char = ']', prob = 30},
				{name = 'Potion of Intellect', char = '!', prob = 31, mut = 5, quaff = true, potion = true, pname = 'Unknown Potion', affect = function () local dice = math.random(1, 2) player_stats.int = player_stats.int + dice end, message = "You feel much smarter."},
				{name = 'Leather Shoes', slot = 'feet', armor = 1, weight = 1, char = '[', prob = 32},
				{name = 'Naginata', slot = 'hand', weptype = 'polearm', subwep = 'naginata', damage = 16, char = ')', weight = 6, prob = 32},
				{name = 'Potion of Mutation', quaff = true, potion = true, mut = 25, char = '!', pname = 'Unknown Potion', affect = function () give_random_mut() end, message = "You just drank a Potion of Mutation!", prob = 32},
				{name = 'Big Stick', slot = 'hand', weptype = 'polearm', subwep = 'hammer', damage = 10, char = ')', weight = 4, prob = 32},
				{name = 'Empty Bottle', char = '!', prob = 33, color = function () love.graphics.setColor(255, 255, 255, 255) end,},
				{name = 'Potion of Strength', char = '!', prob = 34, mut = 5, quaff = true, potion = true, pname = 'Unknown Potion', affect = function () local dice = math.random(1, 2) player_stats.str = player_stats.str + dice end, message = "You feel much stronger."},
				{name = 'Katana', slot = 'hand', weptype = 'longsword', damage = 20, color = function () love.graphics.setColor(200, 200, 200, 255) end, weight = 7, char = ')', apply = true, afunc = function () add_modifier({name = 'Samurai Spirit', turn = 200, power = 5}) end, message = "You feel the spirits of the samurai rush through your veins.", prob = 35},
				{name = 'Potion of Haste', quaff = true, potion = true, pname = 'Unknown Potion', char = '!', prob = 39, affect = function () add_modifier({name = 'Haste', turn = 100, speed = 5}) end, message = "You are now hasted."},
				{name = 'Maid Outfit', slot = 'torso', armor = 3, weight = 6, color = function () love.graphics.setColor(255, 255, 255, 255) end, char = ']', prob = 40},
				{name = 'Silk Bonnet', slot = 'head', armor = 1, weight = 1, color = function () love.graphics.setColor(255, 140, 198, 255) end, char = '[', prob = 41},
				{name = 'Potion of Gain', quaff = true, potion = true, mut = 10, pname = 'Unknown Potion', char = '!', prob = 42, affect = function () local dice = math.random(1, 4) local stat = 'str' if dice == 2 then stat = 'dex' elseif dice == 3 then stat = 'int' elseif dice == 4 then stat = 'con' end player_stats[stat] = player_stats[stat] + 1 end, message = 'You feel like you\'ed gained something.'},
				{name = 'Potion of Loss', quaff = true, potion = true, mut = 5, pname = 'Unknown Potion', char = '!', prob = 42, affect = function () local dice = math.random(1, 4) local stat = 'str' if dice == 2 then stat = 'dex' elseif dice == 3 then stat = 'int' elseif dice == 4 then stat = 'con' end player_stats[stat] = player_stats[stat] - 1 end, message = 'You feel like you\'ed lost something important.'},
				{name = 'Potion of Weakness', quaff = true, potion = true, mut = 10, pname = 'Unkown Potion', char = '!', prob = 43, affect = function () local dice = math.random(1, 1) player_stats.str = player_stats.str - dice end, message = "You feel much weaker."},
				{name = 'Potion of Stupidity', quaff = true, potion = true, mut = 10, pname = 'Unkown Potion', char = '!', prob = 43, affect = function () local dice = math.random(1, 1) player_stats.int = player_stats.int - dice end, message = "You feel much stupider."},
				{name = 'Scroll of Enchant Damage', reads = true, scroll = true, mut = 15, pname = 'Unknown Scroll', char = '?', prob = 44, affect = function () player:base_dam_change(math.random(5, 10)) end, message = "Your hands glow blue for a moment."},
				{name = 'Scroll of Enchant Armor', reads = true, scroll = true, mut = 15, pname = 'Unknown Scroll', char = '?', prob = 44, affect = function () player:armor_change(1) end, message = "Your skin glows blue for a moment."},
				{name = 'Scroll of Remove Armor', reads = true, scroll = true, mut = 15, pname = 'Unknown Scroll', char = '?', prob = 44, affect = function () player:armor_change(math.random(-1, -1)) end, message = "Your skin glows red for a moment."},
				{name = 'Scroll of Remove Damage', reads = true, scroll = true, mut = 15, pname = 'Unknown Scroll', char = '?', prob = 45, affect = function () player:base_dam_change(math.random(-10, -5)) end, message = "Your hands glow red for a moment."},
				{name = 'Robe', slot = 'torso', armor = 2, weight = 5, color = function () love.graphics.setColor(204, 186, 195, 255) end, char = ']', prob = 55},
				{name = 'Sarashi', slot = 'torso', evasion = 1, armor = 1, weight = 1, color = function () love.graphics.setColor(255, 255, 255, 255) end, char = ']', prob = 56},
				{name = 'Potion of Harming', quaff = true, potion = true, pname = 'Unknown Potion', char = '!', prob = 57, affect = function () local dice = math.random(25, 55) player:take_dam(dice, 'pure', 'Potion of Harming') end, message = "That burns!"},
				{name = 'Scroll of Enlightenment', reads = true, scroll = true, pname = 'Unknown Golden Scroll', char = '?', prob = 59, affect = function() enlightenment() end, message = "You feel more knowledgeable about the unknown."},
				{name = 'Fish', edible = true, cook = true, nutrition = 100, char = '%', prob = 60},
				{name = 'Fan', slot = 'hand', weptype = 'stick', apply = true, weight = 2, afunc = function () fan_remove_fog() end, message = "The breeze feels cool on your skin.", damage = 10, char = ')', prob = 65},
				{name = 'Cloth Skirt', slot = 'legs', armor = 2, char = ']', color = function () love.graphics.setColor(204, 202, 186, 255) end, prob = 70},
				{name = 'Cloth Shirt', slot = 'torso', armor = 1, char = ']', color = function () love.graphics.setColor(204, 202, 186, 255) end, prob = 75},
				{name = 'Gohei Stick', slot = 'hand', weptype = 'shinto', damage = 15, char = ')', prob = 80},
				{name = 'Potion of Mana', quaff = true, potion = true, pname = 'Unknown Potion', char = '!', prob = 82, affect = function () player:mheal(100) end, message = "Your magical resources are replenished"},
				{name = 'Potion of Healing', quaff = true, potion = true, pname = 'Unknown Potion', char = '!', prob = 83, affect = function () player:heal(100) end, message = "You feel better."},
				{name = 'Scroll of Return', reads = true, scroll = true, pname = 'Unknown Scroll', char = '?', prob = 85, affect = function () if level.name ~= 'Overworld' then level_connection.up = function () map_overworld(dir) end next_level('up') end end, message = "You are warped back to the entrance."},
				{name = 'Rice Ball', edible = true, cook = true, weight = 1, nutrition = 50, char = '%', prob = 86},
				{name = 'Cloth Pants', slot = 'legs', armor = 1, char = ']', color = function () love.graphics.setColor(204, 202, 186, 255) end, prob = 89},
				{name = 'Leather Vest', slot = 'torso', armor = 2, char = ']', prob = 90},
				{name = 'Dagger', slot = 'hand', weptype = 'shortblade', color = function () love.graphics.setColor(200, 200, 200, 255) end, damage = 18, weight = 4, char = ')', prob = 91},
				{name = 'Loaf of Bread', edible = true, cook = true, nutrition = 135, char = '%', prob = 100},	
				{name = 'Torch', apply = true, applyonce = true, afunc = function () add_modifier({name = 'Lit Torch', turn = 750, torch = 3}) player_fov() next_turn = true end, message = "You light the torch.", char = ':', prob = 125},
				{name = 'Gold', char = '$', weight = 0, gold = math.random(1, 45), color = function () love.graphics.setColor(255, 225, 0, 255) end, prob = 300},			
		}
		
known_potions = {}
known_scrolls = {}

function fan_remove_fog()

	local message = "You wave the fan around."
	for x = player:get_x() - 8, player:get_x() + 8 do
		for y = player:get_y() - 8, player:get_y() + 8 do
			if x > 1 and x < map_width and y > 1 and y < map_height and map[x][y]:get_name() == 'Fog' then
				message = "You wave the fan around.  You blow some fog away!"
				local holding = map[x][y]:get_holding()
				local items = map[x][y]:get_items()
				map[x][y] = Tile:new({name = 'Floor', x = x, y = y})
				map[x][y]:set_holding(holding)
				map[x][y]:set_items(items)				
			end
		end
	end
	map_back_canvas_draw()
	player_fov()
	message_add(message)

end

function cure_mutation()

	if # player_muts > 0 then 
		local dice = math.random(1, # player_muts) 
		table.remove(player_muts, dice) 
	end

end

function enlightenment()

	local items = {}
	local known = false
	
	for i = 1, # game_items do
	
		known = true
	
		if game_items[i].potion then
			known = false
			for k = 1, # known_potions do
				if game_items[i].name == known_potions[i] then 
					known = true
				end
			end
		end
		
		if game_items[i].scroll then
			known = false
			for k = 1, # known_scrolls do
				if game_items[i].name == known_scrolls[i] then
					known = true
				end
			end
		end
		
		if not known then table.insert(items, game_items[i]) end
		
	end
	
	local dice = math.random(1, # items)
	if items[dice].scroll then
		table.insert(known_scrolls, items[dice].name)
	elseif items[dice].potion then
		table.insert(known_potions, items[dice].name)
	end

end