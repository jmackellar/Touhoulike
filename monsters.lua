game_monsters = {	--- unique monsters
					{name = 'Hong Meiling', armor = 7, speed = 1, unique = true, rand_gen = false, base_damage = {100, 125}, hp_max = 3000, exp = 100, char = 'H', color = function () love.graphics.setColor(255, 255, 0, 255) end, level = 4},
					{name = 'Patchouli Knowledge', armor = 5, speed = 1, unique = true, rand_gen = false, base_damage = {140, 150}, hp_max = 2000, exp = 100, char = 'P', color = function () love.graphics.setColor(222, 138, 216, 255) end, level = 5},
					{name = 'Koakuma', armor = 2, speed = 1, unique = true, rand_gen = false, base_damage = {100, 125}, hp_max = 2000, exp = 100, char = 'K', color = function () love.graphics.setColor(150, 150, 150, 255) end, level = 3},
					{name = 'Sakuya Izayoi', armor = 6, speed = -2, unique = true, rand_gen = false, base_damage = {175, 195}, hp_max = 4500, exp = 125, char = 'S', color = function () love.graphics.setColor(0, 0, 255, 255) end, level = 6},
					{name = 'Remilia Scarlet', armor = 8, speed = 1, unique = true, rand_gen = false, base_damage = {215, 225}, hp_max = 5500, exp = 200, char = 'R', color = function () love.graphics.setColor(255, 0, 0, 255) end, level = 7},
					{name = 'Minoriko Aki', armor = 8, speed = 1, unique = true, rand_gen = false, base_damage = {70, 80}, hp_max = 1100, exp = 110, char = 'A', color = function () love.graphics.setColor(209, 61, 61, 255) end, level = 4},
					{name = 'Shizuha Aki', armor = 10, speed = 1, unique = true, rand_gen = false, base_damage = {85, 95}, hp_max = 1400, exp = 120, char = 'A', color = function () love.graphics.setColor(209, 61, 61, 255) end, level = 6},
					{name = 'Tewi Inaba', armor = 10, speed = 1, unique = true, rand_gen = false, base_damage = {145, 155}, hp_max = 2000, exp = 120, char = 'T', color = function () love.graphics.setColor(247, 183, 228, 255) end, level = 4},
					{name = 'Reisen Udongein Inaba', armor = 12, speed = 1, unique = true, rand_gen = false, base_damage = {155, 165}, hp_max = 2400, exp = 130, char = 'R', color = function () love.graphics.setColor(150, 150, 150, 255) end, level = 5},
					{name = 'Eirin Yagokoro', armor = 14, speed = 1, unique = true, rand_gen = false, base_damage = {175, 185}, hp_max = 3000, exp = 155, char = 'E', color = function () love.graphics.setColor(255, 0, 0, 255) end, level = 6},
					{name = 'Kaguya Houraisan', armor = 16, speed = 1, unique = true, rand_gen = false, base_damage = {235, 255}, hp_max = 5000, exp = 250, char = 'K', color = function () love.graphics.setColor(247, 183, 228, 255) end, level = 8},
					--- randomly generated monsters
					{name = 'Small Fairy', armor = 0, base_damage = {15, 20}, rand_gen = true, speed = 1, corpse = 'fairy', hp_max = 185, exp = 10, char = 'f', color = function () love.graphics.setColor(130, 135, 180, 255) end, level = 1}, 	
					{name = 'Frog', armor = 4, base_damage = {15, 20}, rand_gen = true, ai = 'melee', speed = 1, hp_max = 125, exp = 15, char = 't', color = function () love.graphics.setColor(158, 255, 180, 255) end, level = 1},
					{name = 'Turtle', armor = 10, base_damage = {25, 30}, rand_gen = true, ai = 'melee', speed = 2, hp_max = 200, exp = 10, char = 'u', color = function () love.graphics.setColor(0, 255, 0, 255) end, level = 1},
					{name = 'Spirit', armor = 1, base_damage = {20, 25}, speed = 1, rand_gen = true, ai = 'melee', hp_max = 175, exp = 20, char = 's', level = 1},
					{name = 'Fire Fly', armor = 0, base_damage = {15, 20}, rand_gen = true, speed = 1, corpse = 'bug', hp_max = 200, exp = 10, char = 'b', color = function () love.graphics.setColor(255, 255, 0, 255) end, level = 1},
					{name = 'Little Oni', armor = 6, base_damage = {40, 45}, speed = -1, rand_gen = true, ai = 'melee', corpse = 'oni', hp_max = 250, exp = 40, char = 'o', level = 2, color = function () love.graphics.setColor(255, 0, 0, 255) end,},
					{name = 'Tanuki', armor = 3, base_damage = {40, 43}, speed = 1, rand_gen = true, ai = 'melee', hp_max = 250, exp = 25, char = 'd', level = 2, color = function () love.graphics.setColor(255, 140, 140, 255) end,},
					{name = 'Fairy', armor = 2, base_damage = {35, 50}, rand_gen = true, speed = -1, corpse = 'fairy', hp_max = 275, exp = 30, char = 'f', level = 2, color = function () love.graphics.setColor(0, 255, 0, 255) end},
					{name = 'Little Oni Shaman', armor = 4, base_damage = {45, 55}, speed = 1, rand_gen = true, ai = 'ranged', corpse = 'oni', hp_max = 300, exp = 45, char = 'o', level = 3, color = function () love.graphics.setColor(255, 0, 100, 255) end,},
					{name = 'Toad', armor = 7, base_damage = {50, 60}, rand_gen = true, speed = 1, ai = 'melee', hp_max = 350, exp = 50, char = 't', level = 3, color = function () love.graphics.setColor(0, 255, 0, 255) end,},
					{name = 'Rabbit', armor = 8, base_damage = {55, 65}, rand_gen = true, speed = 1, ai = 'melee', corpse = 'rabbit', hp_max = 375, exp = 60, char = 'r', level = 4, color = function () love.graphics.setColor(255, 255, 255, 255) end,},
					{name = 'Rabbit Boss', armor = 9, base_damage = {65, 75}, rand_gen = true, speed = 1, hp_max = 450, corpse = 'rabbit', exp = 65, char = 'r', level = 4, color = function () love.graphics.setColor(150, 150, 150, 255) end,},
				}
				
unique_dead = { }