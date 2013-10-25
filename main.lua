--- Libraries
Gamestate = require "gamestate"
Class = require "middleclass"

--- game states
game = {}
menu = {}

function love.load()

	love.graphics.setCaption("Touhoulike")
	Gamestate.registerEvents()
	Gamestate.switch(menu)

end

--- game state files
require "game"
require "menu"