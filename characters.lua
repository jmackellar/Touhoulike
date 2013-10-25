game_characters = {	{name = 'Reimu Hakurei', stats = {name = 'Player', char = '@', team = 0, x = 25, y = 25, speed = 19, hp_max = 500, mana_max = 200, base_damage = {45, 55}},
					player_stats = { str = 6, dex = 9, int = 5, con = 7 },
					starting_spells = {	{name = 'Omamori of Health', mp_cost = 75, func = function () player:heal(35) end},
										{name = 'Ofuda of Protection', mp_cost = 50, func = function () add_modifier({name = 'Protection', turn = 60, armor = 5}) end}, },
					player_spells_learn = {	{name = 'Power of Hachiman', mp_cost = 55, func = function () add_modifier({name = 'Power', turn = 60, damage = 50}) end, level = 3},
											{name = 'Speed of Fujin', mp_cost = 75, func = function () add_modifier({name = 'Speed', turn = 70, speed = 5}) end, level = 5},
											},
					},
					{name = 'Yukari Yakumo', stats = {name = 'Player', char = '@', team = 0, x = 25, y = 25, speed = 20, hp_max = 550, mana_max = 220, base_damage = {42, 53}},
					player_stats = { str = 7, dex = 8, int = 6, con = 10 },
					starting_spells = {	{name = 'Gap of Unknown', mp_cost = 25, func = function ()
																						local placed = false 
																						repeat 
																							local x = math.random(-10, 10) 
																							local y = math.random(-10, 10) 
																							local continue = true
																							if x > -6 and x < 6 then continue = false end
																							if y > -6 and y < 6 then continue = false end
																							if player:get_x() + x < 1 or player:get_x() + x > map_width then continue = false end
																							if player:get_y() + y < 1 or player:get_y() + y > map_height then continue = false end
																							if continue and map[player:get_x()+x][player:get_y()+y] and not map[player:get_x()+x][player:get_y()+y]:get_block_move() then 
																								for dx = 1, map_width do
																									for dy = 1, map_height do
																										if map[dx][dy]:get_lit() then
																											map[dx][dy]:set_unlit()		
																											map[dx][dy]:set_seen()
																										end
																									end
																								end
																								map[player:get_x()][player:get_y()]:set_holding(nil) 
																								map_new_place_player(player:get_x()+x, player:get_y()+y)
																								placed = true 
																							end 
																						until placed 
																					   end}, 
										},
					player_spells_learn = {
											},
					},
					
				}