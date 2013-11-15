game_spells = {	{name = 'Omamori of Health', mp_cost = 75, func = function () player:heal(35) end},
				{name = 'Ofuda of Protection', mp_cost = 50, func = function () add_modifier({name = 'Protection', turn = 60, armor = 5}) end},
				{name = 'Power of Hachiman', mp_cost = 55, func = function () add_modifier({name = 'Power', turn = 60, damage = 50}) end, level = 3},
				{name = 'Speed of Fujin', mp_cost = 75, func = function () add_modifier({name = 'Speed', turn = 70, speed = 5}) end, level = 5},
				{name = 'Persuasion Needles', mp_cost = 25, func = function () add_modifier({name = 'Needles', turn = 60, bullet = 2}) end},
				{name = 'Border of Distance', mp_cost = 55, func = function () add_modifier({name = 'Distancer', turn = 70, speed = 5, armor = -5, damage = -25}) end},
				}

game_characters = {	{name = 'Reimu Hakurei A', stats = {name = 'Player', char = '@', team = 0, x = 25, y = 25, speed = 19, hp_max = 500, mana_max = 200, base_damage = {45, 55}},
					player_stats = { str = 6, dex = 9, int = 5, con = 7 },
					starting_spells = {	game_spells[1], game_spells[2], },
					player_spells_learn = { {spell = game_spells[3], level = 3}, {spell = game_spells[4], level = 5}, },
					},
					{name = 'Reimu Hakurei B', stats = {name = 'Player', char = '@', team = 0, x = 25, y = 25, speed = 18, hp_max = 400, mana_max = 300, base_damage = {40, 50}},
					player_stats = { str = 4, dex = 8, int = 11, con = 5 },
					starting_spells = { game_spells[5], game_spells[6] },
					player_spells_learn = {	},
					},
					
				}
				