game_items = {	--- items never randomly generated
				{name = 'Ruined Loaf of Bread', edible = true, cook = false, nutrition = 35, char = '%', prob = 0},
				{name = 'Ruined Rice Ball', edible = true, cook = false, nutrition = 5, char = '%', prob = 0},
				{name = 'Ruined Fish', edible = true, cook = false, nutrition = 15, char = '%', prob = 0},
				{name = 'Cooked Loaf of Bread', edible = true, cook = false, nutrition = 200, char = '%', prob = 0},
				{name = 'Cooked Rice Ball', edible = true, cook = false, nutrition = 150, char = '%', prob = 0},
				{name = 'Cooked Fish', edible = true, cook = false, nutrition = 175, char = '%', prob = 0},
				{name = 'Magic Mirror', apply = true, char = '(', message = "You gaze into the mirror.", afunc = function () level_connection['down'] = function (dir) map_hakurei_shrine('up') end next_level('down') end, prob = 0},
				{name = 'Yin-Yang Orb', slot = 'hand', crit = 15, damage = 25, char = ')', prob = 0},
				{name = 'Sweet Potato', edible = true, cook = false, nutrition = 175, char = '%', prob = 0},
				{name = 'Police Baton', slot = 'hand', damage = 30, char = ')', prob = 0},
				{name = 'Bullet-Proof Vest', slot = 'torso', armor = 5, char = ']', prob = 0},
				{name = 'Game Boy', apply = true, afunc = function () end, message = "You activate the doomsday device...", char = '(', prob = 0},
				{name = 'Purification Rod', slot = 'hand', damage = 15, char = ')', prob = 0, bullet = 1},
				--- items randomly generated
				{name = 'Miko Outfit', slot = 'torso', armor = 2, char = ']', prob = 20},
				{name = 'Scroll of Enlightenment', reads = true, scroll = true, pname = 'Unknown Golden Scroll', char = '?', prob = 28, affect = function() enlightenment() end},
				{name = 'Scroll of Magic Mapping', reads = true, scroll = true, pname = 'Unknown Scroll', char = '?', prob = 29, affect = function() for x = 1, map_width do for y = 1, map_height do map[x][y]:set_seen() end end end, message = "An image of the surrounding area forms in your mind."},
				{name = 'Silk Dress', slot = 'legs', armor = 3, char = ']', prob = 30},
				{name = 'Potion of Intellect', char = '!', prob = 31, quaff = true, potion = true, pname = 'Unknown Potion', affect = function () local dice = math.random(1, 2) player_stats.int = player_stats.int + dice end, message = "You feel much smarter."},
				{name = 'Leather Shoes', slot = 'feet', armor = 1, char = '[', prob = 32},
				{name = 'Empty Bottle', char = '!', prob = 33},
				{name = 'Potion of Strength', char = '!', prob = 34, quaff = true, potion = true, pname = 'Unknown Potion', affect = function () local dice = math.random(1, 2) player_stats.str = player_stats.str + dice end, message = "You feel much stronger."},
				{name = 'Katana', slot = 'hand', damage = 20, char = ')', apply = true, afunc = function () add_modifier({name = 'Samurai Spirit', turn = 200, power = 5}) end, message = "You feel the spirits of the samurai rush through your veins.", prob = 35},
				{name = 'Potion of Haste', quaff = true, potion = true, pname = 'Unknown Potion', char = '!', prob = 39, affect = function () add_modifier({name = 'Haste', turn = 100, speed = 5}) end, message = "You are now hasted."},
				{name = 'Maid Outfit', slot = 'torso', armor = 3, char = ']', prob = 40},
				{name = 'Silk Bonnet', slot = 'head', armor = 1, char = '[', prob = 41},
				{name = 'Potion of Gain', quaff = true, potion = true, pname = 'Unknown Potion', char = '!', prob = 42, affect = function () local dice = math.random(1, 4) local stat = 'str' if dice == 2 then stat = 'dex' elseif dice == 3 then stat = 'int' elseif dice == 4 then stat = 'con' end player_stats[stat] = player_stats[stat] + 1 end, message = 'You feel like you\'ed gained something.'},
				{name = 'Potion of Loss', quaff = true, potion = true, pname = 'Unknown Potion', char = '!', prob = 42, affect = function () local dice = math.random(1, 4) local stat = 'str' if dice == 2 then stat = 'dex' elseif dice == 3 then stat = 'int' elseif dice == 4 then stat = 'con' end player_stats[stat] = player_stats[stat] - 1 end, message = 'You feel like you\'ed lost something important.'},
				{name = 'Potion of Weakness', quaff = true, potion = true, pname = 'Unkown Potion', char = '!', prob = 43, affect = function () local dice = math.random(2, 3) player_stats.str = player_stats.str - dice end, message = "You feel much weaker."},
				{name = 'Potion of Stupidity', quaff = true, potion = true, pname = 'Unkown Potion', char = '!', prob = 43, affect = function () local dice = math.random(2, 3) player_stats.int = player_stats.int - dice end, message = "You feel much stupider."},
				{name = 'Scroll of Enchant Damage', reads = true, scroll = true, pname = 'Unknown Scroll', char = '?', prob = 44, affect = function () player:base_dam_change(math.random(5, 10)) end, message = "Your hands glow blue for a moment."},
				{name = 'Scroll of Enchant Armor', reads = true, scroll = true, pname = 'Unknown Scroll', char = '?', prob = 44, affect = function () player:armor_change(1) end, message = "Your skin glows blue for a moment."},
				{name = 'Scroll of Remove Armor', reads = true, scroll = true, pname = 'Unknown Scroll', char = '?', prob = 44, affect = function () player:armor_change(math.random(-2, -1)) end, message = "Your skin glows red for a moment."},
				{name = 'Scroll of Remove Damage', reads = true, scroll = true, pname = 'Unknown Scroll', char = '?', prob = 45, affect = function () player:base_dam_change(math.random(-15, -10)) end, message = "Your hands glow red for a moment."},
				{name = 'Robe', slot = 'torso', armor = 2, char = ']', prob = 55},
				{name = 'Potion of Harming', quaff = true, potion = true, pname = 'Unknown Potion', char = '!', prob = 57, affect = function () local dice = math.random(25, 55) player:take_dam(dice, 'pure', 'Potion of Harming') end, message = "That burns!"},
				{name = 'Fish', edible = true, cook = true, nutrition = 100, char = '%', prob = 60},
				{name = 'Broom', slot = 'hand', apply = true, afunc = function () end, message = "You sweep the ground.", damage = 10, char = ')', prob = 65},
				{name = 'Cloth Skirt', slot = 'legs', armor = 2, char = ']', prob = 70},
				{name = 'Cloth Shirt', slot = 'torso', armor = 1, char = ']', prob = 75},
				{name = 'Gohei Stick', slot = 'hand', damage = 15, char = ')', prob = 80},
				{name = 'Potion of Mana', quaff = true, potion = true, pname = 'Unknown Potion', char = '!', prob = 82, affect = function () player:mheal(100) end, message = "Your magical resources are replenished"},
				{name = 'Potion of Healing', quaff = true, potion = true, pname = 'Unknown Potion', char = '!', prob = 83, affect = function () player:heal(100) end, message = "You feel better."},
				{name = 'Scroll of Return', reads = true, scroll = true, pname = 'Unknown Scroll', char = '?', prob = 85, affect = function () if level.name ~= 'Overworld' then level_connection.up = function () map_overworld(dir) end next_level('up') end end, message = "You are warped back to the entrance."},
				{name = 'Rice Ball', edible = true, cook = true, nutrition = 50, char = '%', prob = 86},
				{name = 'Cloth Pants', slot = 'legs', armor = 1, char = ']', prob = 89},
				{name = 'Leather Vest', slot = 'torso', armor = 2, char = ']', prob = 90},
				{name = 'Dagger', slot = 'hand', damage = 18, char = ')', prob = 91},
				{name = 'Gold', char = '$', gold = math.random(15, 25), prob = 250},
				{name = 'Piece of Junk', char = ';', prob = 300},
				{name = 'Loaf of Bread', edible = true, cook = true, nutrition = 135, char = '%', prob = 300},				
		}
		
known_potions = {}
known_scrolls = {}

function enlightenment()

	local items = {}
	local known = false
	
	for i = 1, # game_items do
	
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