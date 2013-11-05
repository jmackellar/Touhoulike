game_monsters = {	--- unique monsters
					{name = 'Hong Meiling', armor = 7, speed = 8, unique = true, rand_gen = false, base_damage = {65, 75}, hp_max = 1000, exp = 100, char = 'H', color = function () love.graphics.setColor(255, 255, 0, 255) end, level = 4},
					--- randomly generated monsters
					{name = 'Small Fairy', armor = 0, base_damage = {10, 20}, rand_gen = true, speed = 10, hp_max = 175, exp = 10, char = 'f', color = function () love.graphics.setColor(130, 135, 180, 255) end, level = 1}, 	
					{name = 'Frog', armor = 4, base_damage = {15, 20}, rand_gen = true, speed = 15, hp_max = 100, exp = 15, char = 'F', color = function () love.graphics.setColor(158, 255, 180, 255) end, level = 1},
					{name = 'Spirit', armor = 1, base_damage = {20, 25}, rand_gen = true, hp_max = 165, exp = 20, char = 's', level = 1},
				}
				
unique_dead = { }