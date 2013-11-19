game_monsters = {	--- unique monsters
					{name = 'Hong Meiling', armor = 7, speed = 8, unique = true, rand_gen = false, base_damage = {65, 75}, hp_max = 1000, exp = 100, char = 'H', color = function () love.graphics.setColor(255, 255, 0, 255) end, level = 4},
					{name = 'Patchouli Knowledge', armor = 5, speed = 9, unique = true, rand_gen = false, base_damage = {75, 85}, hp_max = 1250, exp = 100, char = 'P', color = function () love.graphics.setColor(222, 138, 216, 255) end, level = 5},
					{name = 'Koakuma', armor = 2, speed = 8, unique = true, rand_gen = false, base_damage = {25, 35}, hp_max = 800, exp = 100, char = 'K', color = function () love.graphics.setColor(150, 150, 150, 255) end, level = 3},
					{name = 'Sakuya Izayoi', armor = 6, speed = 5, unique = true, rand_gen = false, base_damage = {75, 85}, hp_max = 1500, exp = 125, char = 'S', color = function () love.graphics.setColor(0, 0, 255, 255) end, level = 6},
					{name = 'Remilia Scarlet', armor = 8, speed = 7, unique = true, rand_gen = false, base_damage = {95, 105}, hp_max = 2000, exp = 200, char = 'R', color = function () love.graphics.setColor(255, 0, 0, 255) end, level = 7},
					{name = 'Minoriko Aki', armor = 8, speed = 8, unique = true, rand_gen = false, base_damage = {70, 80}, hp_max = 1100, exp = 110, char = 'A', color = function () love.graphics.setColor(209, 61, 61, 255) end, level = 4},
					{name = 'Shizuha Aki', armor = 10, speed = 7, unique = true, rand_gen = false, base_damage = {85, 95}, hp_max = 1400, exp = 120, char = 'A', color = function () love.graphics.setColor(209, 61, 61, 255) end, level = 6},
					--- randomly generated monsters
					{name = 'Small Fairy', armor = 0, base_damage = {10, 20}, rand_gen = true, speed = 10, hp_max = 175, exp = 10, char = 'f', color = function () love.graphics.setColor(130, 135, 180, 255) end, level = 1}, 	
					{name = 'Frog', armor = 4, base_damage = {15, 20}, rand_gen = true, ai = 'melee', speed = 15, hp_max = 100, exp = 15, char = 'F', color = function () love.graphics.setColor(158, 255, 180, 255) end, level = 1},
					{name = 'Spirit', armor = 1, base_damage = {20, 25}, rand_gen = true, ai = 'melee', hp_max = 165, exp = 20, char = 's', level = 1},
					{name = 'Little Oni', armor = 6, base_damage = {35, 40}, rand_gen = true, ai = 'melee', hp_max = 225, exp = 40, char = 'o', level = 2, color = function () love.graphics.setColor(255, 0, 0, 255) end,},
					{name = 'Tanuki', armor = 3, base_damage = {35, 40}, rand_gen = true, ai = 'melee', hp_max = 200, exp = 25, char = 'd', level = 2, color = function () love.graphics.setColor(255, 140, 140, 255) end,},
					{name = 'Fairy', armor = 2, base_damage = {30, 35}, rand_gen = true, speed = 7, hp_max = 200, exp = 30, char = 'f', level = 2, color = function () love.graphics.setColor(0, 255, 0, 255) end},
					{name = 'Little Oni Shaman', armor = 4, base_damage = {44, 55}, rand_gen = true, ai = 'ranged', hp_max = 250, exp = 45, char = 'o', level = 3, color = function () love.graphics.setColor(255, 0, 100, 255) end,},
					{name = 'Toad', armor = 7, base_damage = {45, 50}, rand_gen = true, ai = 'melee', hp_max = 275, exp = 50, char = 't', level = 3, color = function () love.graphics.setColor(0, 255, 0, 255) end,},
				}
				
unique_dead = { }