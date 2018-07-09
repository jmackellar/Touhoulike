ROT = require 'lib/rotLove/rot'

local DEBUG = true
local DEBUGnoFog = false
local DEBUGeditor = false
local DEBUGeditorTile = false 
local DEBUGeditorX = 1
local DEBUGeditorY = 1

local state = 'menu'
local menuSelect = 1
local menuOptions = {'Continue', 'New Game', 'Exit'}
local menuCharacter = {'Reimu Hakurei', 'Marisa Kirisame', 'Alice Margatroid'}

local display = ROT.Display(122, 44)
local scheduler = ROT.Scheduler.Speed()
local fieldOfView = true
local actorsTurn = false

local player = true
local playerMenu = false
local playerMenuSelect = 1
local playerRegenTimer = 30
local playerHunger = 200
local playerHungerTimer = 30
local actors = { }
local itemsOnMap = { }
local inventory = { }
local equipment = {weapon = false, offhand = false, head = false, torso = false, legs = false, hands = false, trinket1 = false, trinket2 = false, trinket3 = false, trinket4 = false}
local map = { }
local messages = { }
local messagesDisp = { }
local danmaku = { }
local mapWidth = 95
local mapHeight = 35

local redraw = true
local lastredraw = 0
local draweffects = false

local calendar = {'Spring', 'Summer', 'Fall', 'Winter'}
local date = {month = 1, day = 1, hour = 12, minute = 0}
local lastTime = 0

local currentLocation = 'hakureishrine'
local currentFloor = 1

local location = {
        gensokyo = {
            name = 'Gensokyo',
            connections = {
                {name = 'hakureishrine', x = 90, y = 16, floor = 1},
                {name = 'marisashouse', x = 82, y = 13, floor = 1},
                {name = 'dampcave', x = 83, y = 16, floor = 1},
                {name = 'aliceshouse', x = 76, y = 18, floor = 1},
                },
            mapdefinition = 'overworld',
            generation = 'mapOverworld',
            floors = 1,
        },
        hakureishrine = {
            name = 'Hakurei Shrine',
            spawn = {x = 56, y = 14},
            connections = {{name = 'gensokyo', x = 4, y = 17, floor = 1}},
            mapdefinition = 'shrine',
            generation = 'mapHakureiShrine',
            floors = 1,
        },
        marisashouse = {
            name = 'Marisa\'s House',
            spawn = {x = 50, y = 14},
            connections = {{name = 'gensokyo', x = 15, y = 29, floor = 1}},
            mapdefinition = 'shrine',
            generation = 'mapMarisasHouse',
            floors = 1,
        }, 
        aliceshouse = {
            name = 'Alice\'s House',
            spawn = {x = 48, y = 14},
            connections = {{name = 'gensokyo', x = 15, y = 29, floor = 1}},
            mapdefinition = 'shrine',
            generation = 'mapAlicesHouse',
            floors = 1,
        },
        dampcave = {
            name = 'Damp Cave',
            connections = {{name = 'gensokyo', x = 45, y = 16, floor = 1}},
            mapdefinition = 'cavern',
            generation = 'mapDampCave',
            floors = 10,
            spawnMonstersOverTime = true,
            lightLevel = 2,
            monsterTable = {
                'littlefairy', 'tinykappa', 'youngoni'
            }
        },    
    }      

local defs = {
        overworld = {
            wall1 = {id = 1, char = string.char(30), bg = ROT.Color.fromString('saddlebrown'), fg = ROT.Color.fromString('rosybrown')},
            floor1 = {id = 0, char = ',', bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('green')},
            floor2 = {id = -1, char = string.char(6), bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('springgreen')},
            floor3 = {id = -2, char = string.char(210), object = {id = 'downstairs', desc = 'Hakurei Shrine', walkOver = 'Hakurei Shrine'}, bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('red')},
            floor4 = {id = -3, char = string.char(127), object = {id = 'downstairs', desc = 'Marisa\'s House', walkOver = 'Marisa\'s House'}, bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('moccasin')},
            floor5 = {id = -4, char = '.', bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('white')},
            floor6 = {id = -5, char = string.char(232), object = {id = 'downstairs', desc = 'Damp Cave', walkOver = 'Damp Cave'}, bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('lightgrey')},
            floor7 = {id = -6, char = string.char(127), object = {id = 'downstairs', desc = 'Alice\'s House', walkOver = 'Alice\'s House'}, bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('rosybrown')}
        },
        shrine = {
            wall1 = {id = 1, char = string.char(6), bg = ROT.Color.fromString('darkgreen'), fg = ROT.Color.fromString('springgreen')},
            wall2 = {id = 2, char = string.char(177), bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('brown')},
            wall3 = {id = 3, char = string.char(177), bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('ivory')},
            wall4 = {id = 4, char = string.char(176), effect = {seeThru = true}, bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('skyblue')},
            floor1 = {id = 0, char = '.', effect = {ondraw = function (self) if love.math.random(1, 100) <= 50 then if self.char == '.' then self.char = ',' else self.char = '.' end end end}, bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('green')},
            floor2 = {id = -1, char = '.', bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('saddlebrown')},
            floor3 = {id = -2, char = '+', bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('white')},
            floor4 = {id = -3, char = '<', object = {id = 'upstairs', desc = 'To Gensokyo', walkOver = 'You see here an exit to Gensokyo.'}, bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('moccasin')},
            floor5 = {id = -4, char = string.char(127), object = {id = 'levelup', name = 'Reimu Hakurei', desc = 'Offering Box', walkOver = 'You see here a dillapidated offering box.'}, bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('moccasin')},
            floor6 = {id = -5, char = ',', bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('yellowgreen')},
            floor7 = {id = -6, char = '\'', effect = {ondraw = function (self) if love.math.random(1, 100) <= 30 then if self.char == '\'' then self.char = '"' else self.char = '\'' end end end}, bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('green')},
            floor8 = {id = -7, char = '.', bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('navajowhite')},
            floor9 = {id = -8, char = string.char(233), object = {id = 'bed', desc = 'Eastern Bed', walkOver = 'You see here a comfortable bed.'}, bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('skyblue')},
            floor10 = {id = -9, char = string.char(233), object = {id = 'bed', desc = 'Western Bed', walkOver = 'You see here a comfortable bed.'}, bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('linen')},
            floor11 = {id = -10, char = string.char(194), object = {id = 'levelup', name = 'Marisa Kirisame', desc = 'Magician\'s Worktable', walkOver = 'You see here a worn table used by an ordinary magician.'}, bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('goldenrod')},
            floor12 = {id = -11, char = string.char(194), object = {id = 'levelup', name = 'Alice Margatroid', desc = 'Dollmaker\'s Desk', walkOver = 'You see here a desk covered with dolls, thread, and needles.'}, bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('ivory')},
        },
        cavern = {
            wall1 = {id = 1, char = string.char(177), bg = ROT.Color.fromString('darkslategrey'), fg = ROT.Color.fromString('lightslategrey')},
            floor1 = {id = 0, char = '.', bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('grey')},
            floor2 = {id = -1, char = '<', object = {id = 'upstairs', desc = 'To Gensokyo', walkOver = 'You see here a staircase leading to the surface.'}, bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('white')},
            floor3 = {id = -2, char = '>', object = {id = 'downstairs', desc = 'Downstairs', walkOver = 'You see a staircase leading downwards.'}, bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('white')},
            floor4 = {id = -3, char = '<', object = {id = 'upstairs', desc = 'Upstairs', walkOver = 'You see a staircase leading upwards.'}, bg = ROT.Color.fromString('black'), fg = ROT.Color.fromString('white')},
        }
    }

local items = {
    ------------------------
    --- Weapons
    ------------------------
    onusa = {
        name = 'Onusa',
        type = 'onusa',
        level = 1,
        desc = '%c{moccasin}A wooden onusa, commonely used for shinto rituals.\n\n%c{goldenrod}Weapon %c{white}+1, 3 - 6',
        equip = 'weapon',
        stats = {meleeDamageMin = 3, meleeDamageMax = 6, accuracy = 1},
        char = '/',
        fgColor = ROT.Color.fromString('navajowhite'),
        bgColor = ROT.Color.fromString('black'),
    },
    magicbroom = {
        name = 'Magic Broom',
        type = 'magicbroom',
        level = 1,
        desc = '%c{moccasin}An old bamboo broom, exposure to magic has caused it to sprout leaves.\n\n%c{goldenrod}Weapon %c{white}+2, 2 - 5',
        equip = 'weapon',
        stats = {meleeDamageMin = 2, meleeDamageMax = 5, accuracy = 2},
        char = '/',
        fgColor = ROT.Color.fromString('rosybrown'),
        bgColor = ROT.Color.fromString('black'),
    },
    threadedneedle = {
        name = 'Threaded Needle',
        type = 'threadedneedle',
        level = 1,
        desc = '%c{moccasin}An iron needled threaded with a light blue silk.\n\n%c{goldenrod}Weapon %c{white}+1, 2 - 4',
        equip = 'weapon',
        stats = {meleeDamageMin = 2, meleeDamageMax = 4, accuracy = 1},
        char = '/',
        fgColor = ROT.Color.fromString('skyblue'),
        bgColor = ROT.Color.fromString('black'),
    },
    ------------------------
    --- Off Hand
    ------------------------
    glowingomamori = {
        name = 'Glowing Omamori',
        type = 'glowingomamori',
        level = 1,
        desc = '%c{moccasin}A bamboo charm written with a prayer of light wrapped in a floral pink silk.\n\n%c{goldenrod}Off Hand\nLight Source %c{white}6',
        equip = 'offhand',
        stats = {lightsource = 6},
        char = string.char(220),
        fgColor = ROT.Color.fromString('pink'),
        bgColor = ROT.Color.fromString('black'),
    },
    magiclantern = {
        name = 'Magic Lantern',
        type = 'magiclantern',
        level = 1,
        desc = '%c{moccasin}A golden lantern enchanted with an elusive ever burning flame.\n\n%c{goldenrod}Off Hand\n%c{goldenrod}Light Source %c{white} 5\n%c{goldenrod}Evasion %c{white}1',
        equip = 'offhand',
        stats = {lightsource = 5, evasion = 1},
        char = string.char(220),
        fgColor = ROT.Color.fromString('gold'),
        bgColor = ROT.Color.fromString('black'),
    },
    brokenhakero = {
        name = 'Broken Hakero',
        type = 'brokenhakero',
        level = 1,
        desc = '%c{moccasin}An octagonal block printed with eight trigrams in a circular pattern.  This model is broken.\n\n%c{goldenrod}Off Hand\n%c{goldenrod}Danmaku %c{white}1 - 3',
        equip = 'offhand',
        stats = {danmakuDamageMin = 1, danmakuDamageMax = 3},
        char = string.char(15),
        fgColor = ROT.Color.fromString('silver'),
        bgColor = ROT.Color.fromString('black'),
    },
    ------------------------
    --- Head
    ------------------------
    witchshat = {
        name = 'Witch Hat',
        type = 'witchshat',
        level = 1,
        desc = '%c{moccasin}A wide brimmed black hat topped with a white bow.\n\n%c{goldenrod}Head %c{white}+1, 0 - 1',
        equip = 'head',
        stats = {evasion = 1, armorMin = 0, armorMax = 1},
        char = '(',
        fgColor = ROT.Color.fromString('white'),
        bgColor = ROT.Color.fromString('black'),
    },
    ------------------------
    --- Torso
    ------------------------
    whitehaori = {
        name = 'White Haori',
        type = 'whitehaori',
        level = 1,
        desc = '%c{moccasin}A white kimono jacket, typically worn by miko.\n\n%c{goldenrod}Torso %c{white}+0, 1 - 3',
        equip = 'torso',
        stats = {armorMin = 1, armorMax = 3, evasion = 0},
        char = ']',
        fgColor = ROT.Color.fromString('white'),
        bgColor = ROT.Color.fromString('black'),
    },
    witchsdress = {
        name = 'Witch Dress',
        type = 'witchsdress',
        level = 1,
        desc = '%c{moccasin}An embroidered black dress adorned by a white smock.\n\n%c{goldenrod}Torso %c{white}+1, 1 - 2',
        equip = 'torso',
        stats = {armorMin = 1, armorMax = 2, evasion = 1},
        char = ']',
        fgColor = ROT.Color.fromString('white'),
        bgColor = ROT.Color.fromString('black'),
    },
    bluedress = {
        name = 'Blue Dress',
        type = 'bluedress',
        level = 1,
        desc = '%c{moccasin}A blue dress adorned with a pink silk ribbon.\n\n%c{goldenrod}Torso %c{white}+0, 1 - 2',
        equip = 'torso',
        stats = {armorMin = 1, armorMax = 2, evasion = 0},
        char = ']',
        fgColor = ROT.Color.fromString('skyblue'),
        bgColor = ROT.Color.fromString('black'),
    },
    ------------------------
    --- Legs
    ------------------------
    redhakama = {
        name = 'Red Hakama',
        type = 'redhakama',
        level = 1,
        desc = '%c{moccasin}A red hakama, typically worn by miko.\n\n%c{goldenrod}Legs %c{white}+0, 1 - 2',
        equip = 'legs',
        stats = {armorMin = 1, armorMax = 2, evasion = 0},
        char = '[',
        fgColor = ROT.Color.fromString('red'),
        bgColor = ROT.Color.fromString('black'),
    },
    ------------------------
    --- Hands
    ------------------------
    dollmakersgloves = {
        name = 'Dollmaker Gloves',
        type = 'dollmakersgloves',
        level = 1,
        desc = '%c{moccasin}A pair of brown leather gloves worn to illuminate a sewer\'s thread.\n\n%c{goldenrod}Hands %c{white}+0, 1 - 2\n%c{goldenrod}Light Source %c{white}6',
        equip = 'hands',
        stats = {armorMin = 1, armorMax = 2, evasion = 0, lightsource = 6},
        char = ')',
        fgColor = ROT.Color.fromString('rosybrown'),
        bgColor = ROT.Color.fromString('black')
    },
    ------------------------
    --- Food
    ------------------------
    uruchimai = {
        name = 'Rice Ball',
        type = 'uruchimai',
        level = 1,
        desc = '%c{moccasin}Ordinary white rice.\n\n%c{goldenrod}Nutrition %c{white}100',
        char = '%',
        fgColor = ROT.Color.fromString('white'),
        bgColor = ROT.Color.fromString('black'),
        nutrition = 100,
    },
    ------------------------
    --- Misc
    ------------------------
    lifepiece = {
        name = 'Life Piece',
        type = 'lifepiece',
        level = 10000,
        desc = '',
        char = string.char(3),
        fgColor = ROT.Color.fromString('pink'),
        bgColor = ROT.Color.fromString('black'),
        noWalkOverText = true,
        onWalkOver =    function (self)
                            table.insert(messages, 1, 'You pickup a life piece!')
                            player.curHealth = math.min(player.maxHealth, player.curHealth + math.ceil(player.maxHealth / 10))
                            for i = 1, # itemsOnMap do 
                                if itemsOnMap[i].x == self.x and itemsOnMap[i].y == self.y then 
                                    table.remove(itemsOnMap, i)
                                    break 
                                end
                            end
                        end,
    },
    power = {
        name = 'Power',
        type = 'power',
        level = 10000,
        desc = '',
        char = 'p',
        fgColor = ROT.Color.fromString('white'),
        bgColor = ROT.Color.fromString('darkred'),
        noWalkOverText = true,
        onWalkOver =    function (self)
                            table.insert(messages, 1, 'You gain power!')
                            player.curPower = math.min(player.curPower + 0.05, player.maxPower)
                            for i = 1, # itemsOnMap do 
                                if itemsOnMap[i].x == self.x and itemsOnMap[i].y == self.y then 
                                    table.remove(itemsOnMap, i)
                                    break 
                                end
                            end
                        end,
    },
    yen = {
        name = 'Yen',
        type = 'yen',
        level = 10000,
        desc = '',
        char = string.char(157),
        fgColor = ROT.Color.fromString('gold'),
        bgColor = ROT.Color.fromString('black'),
        noWalkOverText = true,
        onWalkOver =    function (self)
                            table.insert(messages, 1, 'You pickup some Yen.')
                            player.yen = player.yen + 100
                            for i = 1, # itemsOnMap do 
                                if itemsOnMap[i].x == self.x and itemsOnMap[i].y == self.y then 
                                    table.remove(itemsOnMap, i)
                                    break 
                                end
                            end
                        end,
    },
    corpse = {
        name = 'Corpse',
        type = 'corpse',
        level = 10000,
        desc = '%c{moccasin}A decomposing corpse.  Probably riddled with disease, careful now!',
        char = '%',
        fgColor = ROT.Color.fromString('red'),
        bgColor = ROT.Color.fromString('black'),
    }
}

local monsters = {
    littlefairy = {
        name = 'Little Fairy',
        type = 'littlefairy',
        char = 'f',
        bg = ROT.Color.fromString('black'),
        fg = ROT.Color.fromString('skyblue'),
        bgString = 'black',
        fgString = 'skyblue',
        maxHealth = 10,
        curPower = 0.1,
        meleeDamageMin = 2,
        meleeDamageMax = 4,
        danmakuDamageMin = 1,
        danmakuDamageMax = 2,
        armorMin = 1,
        armorMax = 2,
        evasion = 1,
        accuracy = 4,
        speed = 120,
        canFireDanmaku = true,
        exp = 10,
        alert = false,
        ai = 'simple',
        yen = 100,
        },
    tinykappa = {
        name = 'Tiny Kappa',
        type = 'tinykappa',
        char = 'k',
        bg = ROT.Color.fromString('black'),
        fg = ROT.Color.fromString('springgreen'),
        bgString = 'black',
        fgString = 'springgreen',
        maxHealth = 10,
        curPower = 0.1,
        meleeDamageMin = 3,
        meleeDamageMax = 4,
        danmakuDamageMin = 1,
        danmakuDamageMax = 3,
        armorMin = 2,
        armorMax = 3,
        evasion = 1,
        accuracy = 4,
        speed = 90,
        canFireDanmaku = true,
        exp = 12,
        alert = false, 
        ai = 'simple',
        yen = 100,
        },
    youngoni = {
        name = 'Young Oni',
        type = 'youngoni',
        char = 'o',
        bg = ROT.Color.fromString('black'),
        fg = ROT.Color.fromString('red'),
        bgString = 'black',
        fgString = 'red',
        maxHealth = 15,
        curPower = 0.1,
        meleeDamageMin = 2,
        meleeDamageMax = 6,
        danmakuDamageMin = 0,
        danmakuDamageMax = 1,
        armorMin = 2,
        armorMax = 3,
        evasion = 2,
        accuracy = 5,
        speed = 100,
        canFireDanmaku = false,
        exp = 15,
        alert = false,
        ai = 'simple',
        yen = 100,
    },
    marisakirisame = {
        name = 'Marisa Kirisame',
        type = 'marisakirisame',
        char = '@',
        bg = ROT.Color.fromString('white'),
        fg = ROT.Color.fromString('black'),
        bgString = 'white',
        fgString = 'black',
        maxHealth = 50,
        curPower = 1,
        meleeDamageMin = 8,
        meleeDamageMax = 12,
        danmakuDamageMin = 6,
        danmakuDamageMax = 10,
        armorMin = 3,
        armorMax = 6,
        accuracy = 8,
        evasion = 4,
        speed = 120,
        canFireDanmaku = true,
        exp = 200,
        alert = false, 
        ai = 'simple',
        yen = 1000,
        faction = 'forestofmagic',
        pnoun = true,
        chat = {
            'The fairies have been getting stronger lately.',
            'I can make magical potions from mushrooms found in the forest for you.',
            'Youkai have started moving into the caverns south of here.',
            },
        },
    alicemargatroid = {
        name = 'Alice Margatroid',
        type = 'alicemargatroid',
        char = '@',
        bg = ROT.Color.fromString('navy'),
        fg = ROT.Color.fromString('pink'),
        bgString = 'navy',
        fgString = 'pink',
        maxHealth = 50,
        curPower = 1,
        meleeDamageMin = 8,
        meleeDamageMax = 12,
        danmakuDamageMin = 6,
        danmakuDamageMax = 10,
        armorMin = 3,
        armorMax = 6,
        accuracy = 8,
        evasion = 4,
        speed = 90,
        canFireDanmaku = true,
        exp = 200,
        alert = false,
        ai = 'simple',
        yen = 1000,
        faction = 'forestofmagic',
        pnoun = true,
        chat = {
            'The forest has been getting dangerous lately.',
            '*sigh* I\'ve ran out of thread to make more dolls.',
            'Theres a cavern full of dangerous youkai to the north-east of here.',
            },
        },
    reimuhakurei = {
        name = 'Reimu Hakurei',
        type = 'reimuhakurei',
        char = '@',
        bg = ROT.Color.fromString('red'),
        fg = ROT.Color.fromString('white'),
        bgString = 'red',
        fgString = 'white',
        maxHealth = 50,
        curPower = 1,
        meleeDamageMin = 8,
        meleeDamageMax = 12,
        danmakuDamageMin = 6,
        danmakuDamageMax = 10,
        armorMin = 3,
        armorMax = 6,
        accuracy = 8,
        evasion = 4,
        speed = 100,
        canFireDanmaku = true,
        exp = 200,
        alert = false,
        ai = 'simple',
        yen = 100,
        faction = 'forestofmagic',
        pnoun = true,
        chat = {
            'The youkai have started to ignore spellcard rules lately.',
            'Be careful around the youkai in the forest.',
            'Would you like to make an offering to the Hakurei Shrine?',
            },
        },
    }


--[[ Actors ]]--

local actor = ROT.Class:extend("actor", {speed, x, y, char, fg, bg, maxHealth, curHealth, name, maxPower, curPower, strength, knowledge, spirit, yen, class, exp, level, type, fgString, bgString, meleeDamageMin, meleeDamageMax, danmakuDamageMax, danmakuDamageMin, armorMin, armorMax, evasion, canFireDanmaku, accuracy, ai, alert, id, species, faction, pnoun})
function actor:init(flags)
	self.name = flags.name or 'Testie'
	self.speed = flags.speed or 100
	self.x = flags.x or 1
	self.y = flags.y or 1
	self.char = flags.char or '@'
	self.fg = flags.fg or ROT.Color.fromString('white')
	self.bg = flags.bg or ROT.Color.fromString('black')
	self.maxHealth = flags.maxHealth or 30
	self.curHealth = flags.curHealth or flags.maxHealth or 30
	self.maxPower = flags.maxPower or 1
	self.curPower = flags.curPower or 1
	self.strength = flags.strength or 10
	self.knowledge = flags.knowledge or 10
	self.spirit = flags.spirit or 10
	self.yen = flags.yen or 0
	self.class = flags.class or 'Human'
	self.exp = flags.exp or 10
	self.level = flags.level or 1
    self.type = flags.type or 'random'
    self.fgString = flags.fgString or 'white'
    self.bgString = flags.bgString or 'black'
    self.armorMin = flags.armorMin or 1
    self.armorMax = flags.armorMax or 3
    self.meleeDamageMin = flags.meleeDamageMin or 3
    self.meleeDamageMax = flags.meleeDamageMax or 5
    self.danmakuDamageMin = flags.danmakuDamageMin or 2
    self.danmakuDamageMax = flags.danmakuDamageMax or 4
    self.canFireDanmaku = flags.canFireDanmaku or false
    self.accuracy = flags.accuracy or 5
    self.evasion = flags.evasion or 3
    self.alert = flags.alert or false 
    self.ai = flags.ai or 'simple'
    self.id = tostring(love.math.random(11111, 99999))
    self.species = flags.species or 'Youkai'
    self.faction = flags.faction or 'neutral'
    self.pnoun = flags.pnoun or false
end
function actor:move(dx, dy)
    if map[self.x + dx][self.y + dy].val < 1 then
        --- check for other actors
        local oa = false 
        for i = 1, # actors do
            if actors[i].x == self.x + dx and actors[i].y == self.y + dy then
                oa = actors[i]
            end
        end
        if not oa then
            self.x = self.x + dx 
            self.y = self.y + dy
            if self == player then
                local def = mapLocationDefinition(location[currentLocation].mapdefinition)
                if def['floor'..1 - map[self.x][self.y].val].object then
                    table.insert(messages, 1, def['floor'..1 - map[self.x][self.y].val].object.walkOver)
                end
                for i = # itemsOnMap, 1, -1 do 
                    if itemsOnMap[i].x == self.x and itemsOnMap[i].y == self.y then 
                        if not itemsOnMap[i].noWalkOverText then 
                            local first = string.lower(string.sub(itemsOnMap[i].name, 1, 1))
                            if first == 'a' or first == 'e' or first == 'i' or first == 'o' or first == 'u' then 
                                table.insert(messages, 1, 'You see an ' .. itemsOnMap[i].name .. ' at your feet.')
                            else
                               table.insert(messages, 1, 'You see a ' .. itemsOnMap[i].name .. ' at your feet.')
                            end
                        end
                        if itemsOnMap[i].onWalkOver then 
                            itemsOnMap[i].onWalkOver(itemsOnMap[i])
                        end
                    end
                end
                if not DEBUGnoFog then
                    unlightMap()
                    computeFOV()
                end
            end
            self:endTurn()
            return true
        else
            if self.type == 'player' or oa.type == 'player' then
                self:melee(oa)
                self:endTurn()
                return true
            end
        end
    end
    return false
end
function actor:takeDamage(dam)
    local amin = self.armorMin 
    local amax = self.armorMax 
    if self.type == 'player' then 
        amin = amin + getStat('armorMin')
        amax = amax + getStat('armorMax')
    else
        if self.faction == player.faction then 
            self.faction = 'neutral' 
            if not self.pnoun then 
                table.insert(messages, 1, 'You anger the ' .. self.name .. '.')
            else
                table.insert(messages, 1, 'You anger ' .. self.name .. '.')
            end
        end
    end
    self.curHealth = self.curHealth - math.max(1, dam - love.math.random(self.armorMin, self.armorMax))
    if self.curHealth < 1 then 
        self.curHealth = 0 
        dropItem(newItem('corpse'), self.x, self.y)
        for i = 1, math.ceil(self.curPower * 20) do 
            dropItem(newItem('power'), self.x, self.y)
        end
        if love.math.random(1, 100) <= 20 then 
            for i = 1, math.ceil(self.yen / 100) do
                dropItem(newItem('yen'), self.x, self.y)
            end
        end
        if love.math.random(1, 100) <= 20 then 
            dropItem(newItem('lifepiece'), self.x, self.y)
        end
        if love.math.random(1, 100) <= 20 then 
            for i = 1, love.math.random(1, 2) do
                dropItem(newItem(getRandomItem()), self.x, self.y)
            end
        end
        if self.type ~= 'player' then 
            for i = # actors, 1, -1 do
                if actors[i] == self then 
                    scheduler:remove(actors[i])
                    table.remove(actors, i)
                    break 
                end
            end
        end
    end
end
function actor:melee(target)
    local sa = self.accuracy 
    local ev = target.evasion
    local sdmin = self.meleeDamageMin
    local sdmax = self.meleeDamageMax
    if self.faction ~= target.faction then 
        if self.type == 'player' then 
            sa = sa + getStat('accuracy')
            sdmin = sdmin + getStat('meleeDamageMin')
            sdmax = sdmax + getStat('meleeDamageMax')
        elseif target.type == 'player' then 
            ev = ev + getStat('evasion')
        end
        if love.math.random(1, 20) + sa >= love.math.random(1, 20) + ev then 
            target:takeDamage(love.math.random(sdmin, sdmax))
            if self.type == 'player' then 
                local noun = ''
                if not target.pnoun then noun = ' the ' end
                local msg = 'You hit '.. noun .. target.name .. '!'
                if target.curHealth < 1 then 
                    if not target.pnoun then noun = ' The ' else noun = ' ' end
                    msg = msg .. noun .. target.name .. ' dies!'
                    player.exp = player.exp + target.exp
                end
                table.insert(messages, 1, msg)
            elseif target.type == 'player' then 
                local noun = ''
                if not self.pnoun then noun = 'The ' end
                local msg = noun .. self.name .. ' hits you!'
                if target.curHealth < 1 then 
                    msg = msg .. '  You die...'
                end
                table.insert(messages, 1, msg)
            end
        else
            local noun = ''
            if not target.pnoun then noun = ' the ' end
            if self.type == 'player' then 
                table.insert(messages, 1, 'You miss ' .. noun .. target.name .. '!')
            elseif target.type == 'player' then 
                if not self.pnoun then noun = 'The ' else noun = '' end
                table.insert(messages, 1, noun .. self.name .. ' misses you!')
            end
        end
    elseif self == player and self.faction == target.faction then 
        local chat = monsters[target.type].chat
        if chat and # chat > 0 then 
            table.insert(messages, 1, "'" .. chat[love.math.random(1, # chat)] .. "'")
        end
    end
end
function actor:takeTurn()
    if self.curHealth < 1 then
        self:endTurn()
        return 
    end
    if map[self.x][self.y].lit then self.alert = true end 
    if self.ai == 'simple' then 
        self:simpleAI()
    end
end
function actor:simpleAI()
    local dx = 0
    local dy = 0
    local canmove = true 
    if self.alert then 
        if self.faction ~= player.faction then 
            if self.canFireDanmaku then
                if player.x > self.x and player.y == self.y then 
                    self:fireDanmaku(1, 0)
                    canmove = false
                elseif player.x < self.x and player.y == self.y then 
                    self:fireDanmaku(-1, 0)
                    canmove = false
                elseif player.y > self.y and player.x == self.x then 
                    self:fireDanmaku(0, 1)
                    canmove = false
                elseif player.y < self.y and player.x == self.x then 
                    self:fireDanmaku(0, -1)
                    canmove = false
                elseif math.atan2(player.y - self.y, player.x - self.x) == math.pi / 4 then 
                    self:fireDanmaku(1, 1)
                    canmove = false
                elseif math.atan2(player.y - self.y, player.x - self.x) == 3 * math.pi / 4 then 
                    self:fireDanmaku(-1, 1)
                    canmove = false
                elseif math.atan2(self.y - player.y, self.x - player.x) == math.pi / 4 then 
                    self:fireDanmaku(-1, -1)
                    canmove = false
                elseif math.atan2(self.y - player.y, self.x - player.x) == 3 * math.pi / 4 then 
                    self:fireDanmaku(1, -1)
                    canmove = false
                end
            end
            if canmove then 
                if self.x < player.x then 
                    dx = 1 
                elseif self.x > player.x then 
                    dx = -1
                end
                if self.y < player.y then 
                    dy = 1
                elseif self.y > player.y then 
                    dy = -1
                end
            end
        else 
            dx = love.math.random(-1, 1)
            dy = love.math.random(-1, 1)
        end
        if canmove and not self:move(dx, dy) then
            self:endTurn()
        end
    else
        if not self:move(love.math.random(-1, 1), love.math.random(-1, 1)) then self:endTurn() end
    end
end
function actor:endTurn() 
    if self == player then
        redraw = true
    end
    actorsTurn = scheduler:next() 
    advanceTime(scheduler:getTime() - lastTime)
    lastTime = scheduler:getTime()
    if actorsTurn == player then
        redraw = true 
        updateMessages()
    end
    if self ~= player and not map[self.x][self.y].lit then 
        self.alert = false 
    end
end
function actor:takeDanmakuDamage(d)
    local sdie = love.math.random(1, 20)
    local ddie = love.math.random(1, 20)
    local ev = self.evasion 
    if self == player then 
        ev = ev + getStat('evasion')
    end
    if ddie + d.accuracy >= ev then 
        self:takeDamage(love.math.random(d.dmin, d.dmax))
        if self == player then 
            local msg = 'You are hit by danmaku!'
            if self.curHealth < 1 then 
                self.curHealth = 0
                msg = msg .. '  You die...'
            end
            table.insert(messages, 1, msg)
        else 
            local noun = ''
            if not self.pnoun then noun = 'The ' end
            local msg = noun .. self.name .. ' is hit by danmaku!'
            if self.curHealth < 1 then 
                if not self.pnoun then noun = ' The ' else noun = '' end
                player.exp = player.exp + self.exp
                msg = msg .. noun .. self.name .. ' dies!'
            end
            table.insert(messages, 1, msg)
        end
    else
        if self == player then 
            table.insert(messages, 1, 'You dodge the danmaku!')
        else
            local noun = '' 
            if not self.pnoun then noun = 'The ' end
            table.insert(messages, 1, noun .. self.name .. ' dodges the danmaku!')
        end
    end
end
function actor:fireDanmaku(dx, dy)
    local accuracy = self.accuracy 
    local dmin = self.danmakuDamageMin
    local dmax = self.danmakuDamageMax 
    if self == player then 
        accuracy = accuracy + getStat('accuracy')
        dmin = dmin + getStat('danmakuDamageMin')
        dmax = dmax + getStat('danmakuDamageMax')
    end
    local char = '*'
    local color = ROT.Color.fromString('red')
    if self == player then 
        --- Danmaku visual
        if self.name == 'Reimu Hakurei' then 
            char = string.char(223)
            color = ROT.Color.fromString('indianred')
        elseif self.name == 'Marisa Kirisame' then 
            char = string.char(15)
            color = ROT.Color.fromString('lightskyblue')
        elseif self.name == 'Alice Margatroid' then 
            char = string.char(4)
            color = ROT.Color.fromString('yellow')
        end
        --- Shot types
        fireShotType(dx, dy)
    end
    table.insert(danmaku, {type = self.type, delay = 0, x = self.x, y = self.y, t = 0, dx = dx, dy = dy, accuracy = accuracy, dmin = dmin, dmax = dmax, char = char, fg = color, bg = ROT.Color.fromString('black')})
    self:endTurn()
end
function actor:getSpeed() return self.speed end

--[[ Love2D Callbacks ]]--

function love.load()
	love.window.setTitle('Touhou Jingoku ~Dream in Dreary Dark~')
    love.keyboard.setKeyRepeat(true)
    fieldOfView = ROT.FOV.Precise:new(lightCallback)
    mapSetup(95, 34)
    redraw = true
end

function love.draw()
    if state == 'game' then
        if redraw then
            redraw = false
            display:clear()
        	drawMap()
            drawItems()
            if not DEBUGeditor then
        	   drawActors()
            end
            drawDanmaku()
            drawMessages()
            drawHud()
        end
        --- FPS
        local fps = love.timer.getFPS()
        display:drawText(116, 1, '%c{white}%b{black}FPS:' .. string.sub(tostring(fps), 1, 3))
        if playerMenu ~= 'help' and playerMenu ~= 'messages' then
            display:drawText(116, 34, '%c{white}%b{black}?%c{white}:%c{white}Help')
        end
        display:draw()
        --love.graphics.line(224, 0, 224, 700)
        --love.graphics.line(224, 542, 1200, 542)
    elseif state == 'menu' then
        display:clear()
        display:writeCenter('Touhou Jingoku', 10, ROT.Color.fromString('pink'), ROT.Color.fromString('black'))
        display:writeCenter('~Dream in Dreary Dark~', 11, ROT.Color.fromString('pink'), ROT.Color.fromString('black'))
        for i = 1, # menuOptions do
            local fg = ROT.Color.fromString('white')
            local bg = ROT.Color.fromString('black')
            if menuSelect == i then
                fg = ROT.Color.fromString('black')
                bg = ROT.Color.fromString('white')
                display:writeCenter('XXXXXXXXXXXXXXXXXXXXXX', 30 + i, ROT.Color.fromString('white'), bg)
            end
            display:writeCenter(menuOptions[i], 30 + i, fg, bg)
            if menuOptions[i] == 'New Game' and menuSelect == i and love.filesystem.exists('PLAYER.lua') then
                display:writeCenter('WARNING Starting a new game will overwrite any existing progress.', 40, ROT.Color.fromString('red'), ROT.Color.fromString('black'))
            elseif menuOptions[i] == 'Continue' and menuSelect == i and not love.filesystem.exists('PLAYER.lua') then
                display:writeCenter('WARNING There is no save game to continue from.', 40, ROT.Color.fromString('red'), ROT.Color.fromString('black'))
            end
        end
        display:draw()
    elseif state == 'character' then
        display:clear()
        display:drawText(20, 10, '%c{pink}%b{black}Select a Character')
        for i = 1, # menuCharacter do
            local fg = ROT.Color.fromString('white')
            local bg = ROT.Color.fromString('black')
            if menuSelect == i then
                local title = ''
                local shottype = ''
                fg = ROT.Color.fromString('black')
                bg = ROT.Color.fromString('white')
                display:write('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', 28 - 15, 12 + i, ROT.Color.fromString('white'), bg)
                display:write('Back', 26, 12 + # menuCharacter + 3, ROT.Color.fromString('white'), ROT.Color.fromString('black'))
                if menuCharacter[i] == 'Reimu Hakurei' then 
                    title = 'Shrine Maiden of Paradise'
                    shottype = 'Homing Amulet'
                elseif menuCharacter[i] == 'Marisa Kirisame' then
                    title = 'Ordinary Magician'
                    shottype = 'Piercing Laser'
                elseif menuCharacter[i] == 'Alice Margatroid' then 
                    title = 'Seven-Colored Puppeteer'
                    shottype = 'Shanghai Doll'
                end
                display:drawText(60, 13, '%c{white}'..title)
                display:drawText(60, 14, '%c{gold}Shot Type : %c{white}'..shottype)
            elseif menuSelect > # menuCharacter then 
                display:write('XXXXXXXXXXXX', 22, 12 + # menuCharacter + 3, ROT.Color.fromString('white'), ROT.Color.fromString('white'))
                display:write('Back', 26, 12 + # menuCharacter + 3, ROT.Color.fromString('black'), ROT.Color.fromString('white'))
            end
            display:write(menuCharacter[i], 28 - math.floor(string.len(menuCharacter[i]) / 2), 12 + i, fg, bg)
            if love.filesystem.exists('PLAYER.lua') then 
                display:writeCenter('WARNING Starting a new game will overwrite any existing progress.', 40, ROT.Color.fromString('red'), ROT.Color.fromString('black'))
            end
        end
        display:draw()
    end
end

function love.update(dt)
    updateMessages(true)
    if state == 'game' then
        updateDanmaku(dt)
        lastredraw = lastredraw + dt 
        if lastredraw > 0.25 then
            lastredraw = 0
            redraw = true 
            draweffects = true
        end
    	if not actorsTurn then
            actorsTurn = scheduler:next()
        else
            if actorsTurn.type ~= 'player' and # danmaku < 1 then
                repeat
                    actorsTurn:takeTurn()
                until not actorsTurn or actorsTurn.type == 'player' or player.curHealth == 0
            end
        end
    elseif state == 'menu' then
        if menuSelect < 1 then 
            menuSelect = # menuOptions
        elseif menuSelect > # menuOptions then
            menuSelect = 1
        end
    elseif state == 'character' then
        if menuSelect < 1 then
            menuSelect = # menuCharacter + 1
        elseif menuSelect > # menuCharacter + 1 then
            menuSelect = 1 
        end
    end
end

function love.keypressed(key, isrepeat)
    if state == 'game' then
        if not actorsTurn then return end
        if DEBUG then
            if key == 'f1' then
                if DEBUGnoFog then
                    DEBUGnoFog = false 
                    table.insert(messages, 1, 'DEBUG: Enabled FoV.')
                    updateMessages()
                else 
                    DEBUGnoFog = true 
                    table.insert(messages, 1, 'DEBUG: Disabled FoV.')
                    updateMessages()
                end
                redraw = true
            elseif key == 'f2' then
                if DEBUGeditor then
                    DEBUGeditor = false 
                    table.insert(messages, 1, 'DEBUG: Exiting tile editor mode.')
                    updateMessages()
                else
                    DEBUGeditor = true 
                    DEBUGeditorTile = mapLocationDefinition(location[currentLocation].mapdefinition).wall1
                    table.insert(messages, 1, 'DEBUG: Entering tile editor mode.')
                    updateMessages()
                end
            end
        end
        if DEBUGeditor then
            if key == 'x' then
                local tble = { }
                for k,v in pairs(mapLocationDefinition(location[currentLocation].mapdefinition)) do
                    table.insert(tble, v)
                end
                for i = 1, # tble do
                    if DEBUGeditorTile == tble[i] then
                        if i == # tble then
                            DEBUGeditorTile = tble[1]
                        else
                            DEBUGeditorTile = tble[i+1]
                        end
                        break
                    end
                end
            end
            if key == 'up' then
                DEBUGeditorY = DEBUGeditorY - 1
                redraw = true
            elseif key == 'down' then
                DEBUGeditorY = DEBUGeditorY + 1
                redraw = true
            end
            if key == 'left' then
                DEBUGeditorX = DEBUGeditorX - 1
                redraw = true
            elseif key == 'right' then
                DEBUGeditorX = DEBUGeditorX + 1
                redraw = true
            end
            if key == 'z' then
                map[DEBUGeditorX][DEBUGeditorY].val = DEBUGeditorTile.id
                redraw = true
            end
            if key == 'c' then
                local tosave = 'local map = { }\n'
                tosave = tosave .. 'for x = 1, 95 do map[x] = { } for y = 1, 34 do map[x][y] = {val = 0} end end\n'
                tosave = tosave .. 'local location = \'' .. currentLocation ..'\'\n'
                for x = 1, 95 do
                    for y = 1, 34 do
                        tosave = tosave .. 'map['..x ..']['..y ..'].val = '..map[x][y].val ..'\n'
                    end
                end
                tosave = tosave .. 'return map, location\n'
                love.filesystem.write('map.lua', tosave)
                table.insert(messages, 1, 'DEBUG: Saved custom map to file.')
                updateMessages()
            end
        end
        if actorsTurn.type == 'player' and not DEBUGeditor and player.curHealth > 0 then
            if not playerMenu then
                if key == 'j' then
                    actorsTurn:move(0, 1)
                elseif key == 'k' then
                    actorsTurn:move(0, -1)
                elseif key == 'h' then
                    actorsTurn:move(-1, 0)
                elseif key == 'l' then
                    actorsTurn:move(1, 0)
                elseif key == 'y' then
                    actorsTurn:move(-1, -1)
                elseif key == 'u' then
                    actorsTurn:move(1, -1)
                elseif key == 'b' then
                    actorsTurn:move(-1, 1)
                elseif key == 'n' then
                    actorsTurn:move(1, 1)
                elseif key == '.' and not (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) then 
                    actorsTurn:endTurn()
                end
                if key == 'f' then 
                    table.insert(messages, 1, 'Fire danmaku in which direction?')
                    updateMessages()
                    playerMenu = 'danmaku'
                end
                if key == 'e' then 
                    local order = {'weapon', 'offhand', 'head', 'torso', 'legs', 'hands', 'trinket1', 'trinket2', 'trinket3', 'trinket4'}
                    for i = 1, 10 do 
                        if equipment[order[i]] then 
                            menuSelect = i 
                            break 
                        end
                    end
                    playerMenu = 'equipment'
                    redraw = true
                end
                if key == 'm' then 
                    playerMenu = 'messages'
                    redraw = true
                end
                if key == 'i' then 
                    playerMenu = 'inventory'
                    menuSelect = 1
                    redraw = true
                end
                if key == 's' and (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) then 
                    saveGame()
                    table.insert(messages, 1, 'Game has been saved!')
                    updateMessages()
                end
                if key == 'return' then 
                    if getDefinitationOfTile(player.x, player.y).object and getDefinitationOfTile(player.x, player.y).object.id == 'bed' then
                        table.insert(messages, 1, 'You lay down and close your eyes.  You slowly begin to fall asleep...')
                        for i = 1, 7 do
                          advanceTime(60, true)
                        end
                        table.insert(messages, 1, '...You wake up stretching your arms out.  You feel well rested.')
                    elseif getDefinitationOfTile(player.x, player.y).object and getDefinitationOfTile(player.x, player.y).object.id == 'levelup' then
                        if getDefinitationOfTile(player.x, player.y).object.name == player.name then
                            playerMenu = 'levelup'
                            menuSelect = 1
                            redraw = true
                        else 
                            table.insert(messages, 1, 'You aren\'t quite sure how to use this '.. getDefinitationOfTile(player.x, player.y).object.desc .. '.')
                        end 
                    end
                    updateMessages()
                end
                if key == 'g' then 
                    for i = # itemsOnMap, 1, -1 do 
                        if itemsOnMap[i].x == player.x and itemsOnMap[i].y == player.y then 
                            if # inventory < 25 then
                                local first = string.lower(string.sub(itemsOnMap[i].name, 1, 1))
                                local msg = 'You pickup a '
                                if first == 'a' or first == 'e' or first == 'i' or first == 'o' or first == 'u' then 
                                    msg = 'You pickup an '
                                end
                                msg = msg .. itemsOnMap[i].name .. '.'
                                table.insert(messages, 1, msg)
                                table.insert(inventory, itemsOnMap[i])
                                table.remove(itemsOnMap, i)
                                player:endTurn()
                            else 
                                table.insert(messages, 1, 'You don\'t have enough room in your pack to fit that!')
                            end
                        end
                    end
                end
                if key == ',' and (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) then
                    if getDefinitationOfTile(player.x, player.y).object and getDefinitationOfTile(player.x, player.y).object.id == 'upstairs' then
                        useUpstairs(player.x, player.y)
                        player:endTurn()
                    end
                elseif key == '.' and (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) then
                    if getDefinitationOfTile(player.x, player.y).object and getDefinitationOfTile(player.x, player.y).object.id == 'downstairs' then
                        useDownstairs(player.x, player.y)
                        player:endTurn()
                    end
                end
                if key == '/' and (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')) then 
                    playerMenu = 'help'
                    redraw = true
                end
            elseif playerMenu == 'levelup' then 
                if key == 'space' or key == 'escape' then 
                    playerMenu = false 
                    redraw = true 
                end
                if key == 'return' then 
                    local options = {'Health', 'Power', 'Strength', 'Knowledge', 'Spirit', 'Accuracy', 'Evasion'}
                    if player.exp >= 0 + ((player.level-1)^3)*10 then 
                        player.level = player.level + 1
                        player.exp = player.exp - (100 + ((player.level-1)^3)*10)
                        playerMenu = false 
                        redraw = true 
                        table.insert(messages, 1, 'You feel more powerful!')
                        player:endTurn()
                        if options[menuSelect] == 'Health' then 
                            player.maxHealth = player.maxHealth + 5
                        elseif options[menuSelect] == 'Power' then 
                            player.maxPower = player.maxPower + 0.15
                        elseif options[menuSelect] == 'Strength' then 
                            player.strength = player.strength + 1
                        elseif options[menuSelect] == 'Knowledge' then 
                            player.knowledge = player.knowledge + 1
                        elseif options[menuSelect] == 'Spirit' then 
                            player.spirit = player.spirit + 1
                        elseif options[menuSelect] == 'Accuracy' then 
                            player.accuracy = player.accuracy + 1
                        elseif options[menuSelect] == 'Evasion' then 
                            player.evasion = player.evasion + 1
                        end
                    end
                end
                if key == 'j' then 
                    menuSelect = menuSelect + 1 
                    redraw = true
                    if menuSelect > 7 then 
                        menuSelect = 1
                    end
                end
                if key == 'k' then 
                    menuSelect = menuSelect - 1 
                    redraw = true
                    if menuSelect < 1 then 
                        menuSelect = 7 
                    end
                end
            elseif playerMenu == 'danmaku' then 
                if key == 'j' then
                    actorsTurn:fireDanmaku(0, 1)
                    playerMenu = false 
                elseif key == 'k' then
                    actorsTurn:fireDanmaku(0, -1)
                    playerMenu = false 
                elseif key == 'h' then
                    actorsTurn:fireDanmaku(-1, 0)
                    playerMenu = false 
                elseif key == 'l' then
                    actorsTurn:fireDanmaku(1, 0)
                    playerMenu = false 
                elseif key == 'y' then
                    actorsTurn:fireDanmaku(-1, -1)
                    playerMenu = false 
                elseif key == 'u' then
                    actorsTurn:fireDanmaku(1, -1)
                    playerMenu = false 
                elseif key == 'b' then
                    actorsTurn:fireDanmaku(-1, 1)
                    playerMenu = false 
                elseif key == 'n' then
                    actorsTurn:fireDanmaku(1, 1)
                    playerMenu = false 
                end
                if key == 'space' or key == 'return' or key == 'escape' then 
                    table.insert(messages, 1, 'Nevermind.')
                    updateMessages()
                    playerMenu = false 
                end
            elseif playerMenu == 'inventory' then 
                if key == 'e' then 
                    local order = {'weapon', 'offhand', 'head', 'torso', 'legs', 'hands', 'trinket1', 'trinket2', 'trinket3', 'trinket4'}
                    for i = 1, 10 do 
                        if equipment[order[i]] then 
                            menuSelect = i 
                            break 
                        end
                    end
                    playerMenu = 'equipment'
                    redraw = true 
                end
                if key == 'space' or key == 'escape' or key == 'i' then 
                    playerMenu = false 
                    redraw = true
                end
                if key == 'return' and inventory[menuSelect] then 
                    if inventory[menuSelect].equip then 
                        local i = inventory[menuSelect]
                        local msg = ''
                        table.remove(inventory, menuSelect)
                        if equipment[i.equip] then 
                            table.insert(inventory, equipment[i.equip])
                            msg = msg .. 'You put the ' .. equipment[i.equip].name .. ' into your pack.  '
                        end
                        msg = msg .. 'You equip the ' .. i.name .. '.'
                        table.insert(messages, 1, msg)
                        player:endTurn()
                        equipment[i.equip] = i
                        playerMenu = false
                    elseif inventory[menuSelect].nutrition then 
                        local msg = 'You eat the ' .. inventory[menuSelect].name .. '.'
                        if player.species == 'Human' then 
                            msg = msg .. '  You feel full after that meal.'
                            playerHunger = math.max(200, playerHunger + inventory[menuSelect].nutrition)
                        else
                            msg = msg .. '  That was tasty!'
                        end
                        table.remove(inventory, menuSelect)
                        table.insert(messages, 1, msg)
                        player:endTurn()
                        playerMenu = false
                    end
                end
                if key == 'j' then 
                    menuSelect = menuSelect + 1 
                    if menuSelect > # inventory then 
                        menuSelect = 1 
                    end 
                    redraw = true
                elseif key == 'k' then 
                    menuSelect = menuSelect - 1 
                    if menuSelect < 1 then 
                        menuSelect = # inventory
                    end
                    redraw = true
                end
                if key == 'd' and inventory[menuSelect] then 
                    dropItem(inventory[menuSelect], player.x, player.y)
                    table.insert(messages, 1, 'You dropped the ' .. inventory[menuSelect].name ..'.')
                    table.remove(inventory, menuSelect)
                    menuSelect = math.max(1, menuSelect - 1)
                    playerMenu = false 
                    player:endTurn()
                    redraw = true
                end
            elseif playerMenu == 'equipment' then 
                local order = {'weapon', 'offhand', 'head', 'torso', 'legs', 'hands', 'trinket1', 'trinket2', 'trinket3', 'trinket4'}
                if key == 'return' then 
                    if equipment[order[menuSelect]] then 
                        table.insert(inventory, equipment[order[menuSelect]])
                        table.insert(messages, 1, 'You put the ' .. equipment[order[menuSelect]].name .. ' into your pack.')
                        equipment[order[menuSelect]] = false
                        playerMenu = false
                        player:endTurn()
                    end
                end
                if key == 'j' then 
                    for i = 1, 10 do 
                        menuSelect = menuSelect + 1 
                        if menuSelect > 10 then 
                            menuSelect = 1 
                        end
                        if equipment[order[menuSelect]] then 
                            break 
                        end
                    end
                    redraw = true
                elseif key == 'k' then 
                    for i = 1, 10 do 
                        menuSelect = menuSelect - 1 
                        if menuSelect < 1 then 
                            menuSelect = 10 
                        end
                        if equipment[order[menuSelect]] then 
                            break 
                        end
                    end
                    redraw = true
                end
                if key == 'i' then 
                    playerMenu = 'inventory'
                    menuSelect = 1
                    redraw = true 
                end
                if key == 'e' or key == 'space' or key == 'escape' then 
                    redraw = true 
                    playerMenu = false
                end
            elseif playerMenu == 'help' or playerMenu == 'messages' then 
                if key then 
                    redraw = true
                    playerMenu = false 
                end
            end
        end
    elseif state == 'menu' then
        if key == 'up' or key == 'k' then
            menuSelect = menuSelect - 1
        elseif key == 'down' or key == 'j' then
            menuSelect = menuSelect + 1
        end
        if key == 'return' or key == 'space' then
            local op = menuOptions[menuSelect]
            if op == 'New Game' then
                state = 'character'
                menuSelect = 1
            elseif op == 'Exit' then
                love.event.push('quit')
            elseif op == 'Continue' then
                if love.filesystem.exists('PLAYER.lua') then
                    loadGame()
                    state = 'game'
                end
            end
        end
    elseif state == 'character' then
        if key == 'up' or key == 'k' then
            menuSelect = menuSelect - 1
        elseif key == 'down' or key == 'j' then
            menuSelect = menuSelect + 1
        end
        if key == 'return' or key == 'space' then
            local op = menuCharacter[menuSelect]
            if op then 
                local toDelete = love.filesystem.getDirectoryItems('/')
                for i = 1, # toDelete do
                    love.filesystem.remove(toDelete[i])
                end
            end
            if op == 'Reimu Hakurei' then
                player = actor:new(
                    {
                        name = 'Reimu Hakurei',
                        class = 'Shrine Maiden',
                        species = 'Human',
                        type = 'player',
                        x = 2,
                        y = 2,
                        bg = ROT.Color.fromString('red'),
                        fg = ROT.Color.fromString('white'),
                        bgString = 'red',
                        fgString = 'white',
                        strength = 7,
                        knowledge = 4,
                        spirit = 12,
                        maxHealth = 30,
                        curHealth = 30,
                        maxPower = 1,
                        curPower = 0,
                        yen = 0,
                        exp = 0,
                        meleeDamageMin = 3,
                        meleeDamageMax = 6,
                        danmakuDamageMin = 2,
                        danmakuDamageMax = 4,
                        armorMin = 3,
                        armorMax = 5,
                        accuracy = 10,
                        evasion = 6,
                        faction = 'forestofmagic',
                    }
                )
                state = 'game'
                mapChangeLocation('hakureishrine', false, true, true)
                table.insert(messages, 1, 'You awaken to a dream in dreary dark.')
                updateMessages()
            elseif op == 'Marisa Kirisame' then
                player = actor:new(
                {   
                    name = 'Marisa Kirisame',
                    class = 'Magician',
                    species = 'Human',
                    type = 'player',
                    x = 2,
                    y = 2,
                    bg = ROT.Color.fromString('white'),
                    fg = ROT.Color.fromString('black'),
                    bgString = 'white',
                    fgString = 'black',
                    strength = 4,
                    knowledge = 15,
                    spirit = 5,
                    maxHealth = 20,
                    curHealth = 20,
                    maxPower = 1,
                    curPower = 0,
                    yen = 1000,
                    exp = 0,
                    meleeDamageMin = 2,
                    meleeDamageMax = 4,
                    danmakuDamageMin = 3,
                    danmakuDamageMax = 5,
                    armorMin = 2,
                    armorMax = 4,
                    accuracy = 10,
                    evasion = 7,
                    faction = 'forestofmagic',
                    speed = 120,
                })
                state = 'game'
                mapChangeLocation('marisashouse', false, true, true)
                table.insert(messages, 1, 'You awaken to a dream in dreary dark.')
                updateMessages()
            elseif op == 'Alice Margatroid' then 
                player = actor:new(
                {   
                    name = 'Alice Margatroid',
                    class = 'Magician',
                    species = 'Youkai',
                    type = 'player',
                    x = 2,
                    y = 2,
                    bg = ROT.Color.fromString('navy'),
                    fg = ROT.Color.fromString('pink'),
                    bgString = 'navy',
                    fgString = 'pink',
                    strength = 3,
                    knowledge = 14,
                    spirit = 7,
                    maxHealth = 25,
                    curHealth = 25,
                    maxPower = 1,
                    curPower = 0,
                    yen = 1000,
                    exp = 0,
                    meleeDamageMin = 1,
                    meleeDamageMax = 4,
                    danmakuDamageMin = 2,
                    danmakuDamageMax = 6,
                    armorMin = 2,
                    armorMax = 4,
                    accuracy = 10,
                    evasion = 7,
                    faction = 'forestofmagic',
                    speed = 90,
                })
                state = 'game'
                mapChangeLocation('aliceshouse', false, true, true)
                table.insert(messages, 1, 'You awaken to a dream in dreary dark.')
                updateMessages()
            else
                state = 'menu'
            end
        end
    end
end

--[[ Drawing ]]--

function drawDanmaku()
    for i = 1, # danmaku do
        local d = danmaku[i] 
        display:write(d.char, 27 + math.floor(d.x), math.floor(d.y), d.fg, d.bg)
    end
end

function drawItems()
    for i = 1, # itemsOnMap do 
        local i = itemsOnMap[i]
        if map[i.x][i.y].seen then 
            local fgc = i.fgColor 
            local bgc = i.bgColor
            if not map[i.x][i.y].lit then 
                fgc = ROT.Color.interpolate(fgc, ROT.Color.fromString('black'), 0.5)
                bgc = ROT.Color.interpolate(bgc, ROT.Color.fromString('black'), 0.5)
            end
            display:write(i.char, i.x + 27, i.y, fgc, bgc)
        end
    end
end

function drawMessages()
    local limit = 6
    if playerMenu ~= 'messages' then
        drawFrame(28, 35, 94, 9)
    else 
        drawFrame(28, 1, 94, 43)
        limit = 40
    end
    --- Write latest messages
    for i = 1, limit do
        if messagesDisp[i] then
            local color = 'white'
            if messagesDisp[i].turn == 2 then 
                color = 'darkgrey'
            elseif messagesDisp[i].turn > 2 then 
                color = 'grey'
            end
            display:drawText(31, 43  - i, '%b{black}%c{'..color ..'}'..messagesDisp[i].msg)
        end
    end
end

function drawFrame(sx, sy, w, h, color)
    if not color then color = ROT.Color.fromString('white') end
    for y = sy, sy + h do 
        for x = sx, sx + w do 
            display:write('X', x, y, ROT.Color.fromString('black'), ROT.Color.fromString('black'))
            if y == sy and x == sx then 
                display:write(string.char(218), x, y, color, ROT.Color.fromString('black'))
            elseif y == sy and x == sx + w then 
                display:write(string.char(191), x, y, color, ROT.Color.fromString('black'))
            elseif y == sy and x > sx and x < sx + w then 
                display:write(string.char(196), x, y, color, ROT.Color.fromString('black'))
            elseif x == sx and y > sy and y < sy + h then 
                display:write(string.char(179), x, y, color, ROT.Color.fromString('black'))
            elseif x == sx + w and y > sy and y < sy + h then 
                display:write(string.char(179), x, y, color, ROT.Color.fromString('black'))
            elseif y == sy + h and x > sx and x < sx + w then 
                display:write(string.char(196), x, y, color, ROT.Color.fromString('black'))
            elseif y == sy + h and x == sx then 
                display:write(string.char(192), x, y, color, ROT.Color.fromString('black'))
            elseif y == sy + h and x == sx + w then 
                display:write(string.char(217), x, y, color, ROT.Color.fromString('black'))
            end
        end
    end
end

function drawPlayerMenu()
    if playerMenu == 'inventory' then 
        local sy = 17 + math.floor((1 - # inventory) / 2)
        local y = sy
        drawFrame(58 - 15, sy - 2, 30, # inventory + 3)
        y = sy
        for i = 1, # inventory do 
            local bg = 'black'
            local fg = 'white'
            if menuSelect == i then 
                bg = 'white'
                fg = 'black'
                local desc = inventory[i].desc
                local width, lines = ROT.Text.measure(desc, 30)
                drawFrame(59 + 15, sy - 2, 33, lines + 1)
                display:drawText(58 - 10, y, '%b{white}%c{white}XXXXXXXXXXXXXXXXXXXXXj')
                display:drawText(77, sy - 1, '%b{black}%c{white}'..desc, 30)
            end
            display:drawText(58 - math.floor(string.len(inventory[i].name) / 2), y, '%b{'..bg ..'}%c{'..fg ..'}'..inventory[i].name)
            y = y + 1
        end
        display:drawText(58 - 13, sy + # inventory + 1, '%b{black}%c{white}[enter] Use/Equip  [d] Drop')
        display:drawText(54, sy - 2, '%b{black}%c{white}Inventory')
    elseif playerMenu == 'levelup' then 
        drawFrame(50, 10, 49, 14)
        display:drawText(71, 10, '%b{black}%c{white}Levelup')
        if player.exp >= 100 + ((player.level-1)^3) * 10 then 
            display:drawText(53, 13, '%b{black}%c{gold}Current Level : %c{springgreen}' .. player.level .. ' -> ' .. player.level + 1)
            display:drawText(53, 14, '%b{black}%c{gold}Required Exp  : %c{white}' .. 100 + ((player.level-1)^3) * 10)
        else
            display:drawText(53, 13, '%b{black}%c{gold}Current Level : %c{white}' .. player.level)
            display:drawText(53, 14, '%b{black}%c{gold}Required Exp  : %c{red}' .. 100 + ((player.level-1)^3) * 10)
        end
        display:drawText(53, 16, '%b{black}%c{gold}Class : %c{white}' .. player.class)
        display:drawText(52, 24, '%b{black}%c{white}[enter] Increase Stat  [space] Close')
        local options = {'Health', 'Power', 'Strength', 'Knowledge', 'Spirit', 'Accuracy', 'Evasion'}
        local y = 13
        for i = 1, # options do 
            if i == menuSelect then 
                local c = 'springgreen'
                if player.exp < 100 + ((player.level-1)^3) * 10 then 
                    c = 'red'
                end
                if options[i] == 'Health' then 
                    display:drawText(53, 18, '%b{black}%c{goldenrod}Max Health : %c{'..c ..'}' .. player.maxHealth .. ' -> ' .. player.maxHealth + 5)
                elseif options[i] == 'Power' then
                    display:drawText(53, 18, '%b{black}%c{goldenrod}Max Power : %c{'..c ..'}' .. player.maxPower .. ' -> ' .. player.maxPower + 0.15)
                elseif options[i] == 'Strength' then 
                    display:drawText(53, 18, '%b{black}%c{goldenrod}Strength : %c{'..c ..'}' .. player.strength .. ' -> ' .. player.strength + 1)
                elseif options[i] == 'Knowledge' then
                    display:drawText(53, 18, '%b{black}%c{goldenrod}Knowledge : %c{'..c ..'}' .. player.knowledge .. ' -> ' .. player.knowledge + 1)
                elseif options[i] == 'Spirit' then 
                    display:drawText(53, 18, '%b{black}%c{goldenrod}Spirit : %c{'..c ..'}' .. player.spirit .. ' -> ' .. player.spirit + 1)
                elseif options[i] == 'Accuracy' then 
                    display:drawText(53, 18, '%b{black}%c{goldenrod}Accuracy : %c{'..c ..'}' .. player.accuracy .. ' -> ' .. player.accuracy + 1)
                elseif options[i] == 'Evasion' then 
                    display:drawText(53, 18, '%b{black}%c{goldenrod}Evasion : %c{'..c ..'}' .. player.evasion .. ' -> ' .. player.evasion + 1)
                end
            end
            if menuSelect == i then 
                display:drawText(79, y, '%b{white}%c{white}XXXXXXXXXXXXXXXXX')
                display:drawText(83, y, '%b{white}%c{black}'..options[i])
            else
                display:drawText(83, y, '%b{black}%c{white}'..options[i])
            end
            if i == 2 then y = y + 1 end 
            if i == 5 then y = y + 1 end 
            y = y + 1
        end
    elseif playerMenu == 'equipment' then 
        local sy = 11
        local sx = 58
        local y = sy + 1
        local order = {'weapon', 'offhand', 'head', 'torso', 'legs', 'hands', 'trinket1', 'trinket2', 'trinket3', 'trinket4'}
        local disp = {
            weapon =    '%c{white}%b{black}Weapon   %c{grey}:',
            offhand =   '%c{white}%b{black}Off Hand %c{grey}:',
            head =      '%c{white}%b{black}Head     %c{grey}:',
            torso =     '%c{white}%b{black}Torso    %c{grey}:',
            legs =      '%c{white}%b{black}Legs     %c{grey}:',
            hands =     '%c{white}%b{black}Hands    %c{grey}:',
            trinket1 =  '%c{white}%b{black}Ring     %c{grey}:',
            trinket2 =  '%c{white}%b{black}Earrings %c{grey}:',
            trinket3 =  '%c{white}%b{black}Necklace %c{grey}:',
            trinket4 =  '%c{white}%b{black}Ribbon   %c{grey}:'
        }
        drawFrame(sx - 15, sy - 1, 30, 15)
        display:drawText(sx-4, sy - 1, '%b{black}Equipment')
        display:drawText(sx - 13, sy + 14, '%b{black}[enter] Unequip')
        for i = 1, # order do
            local colors = '%b{black}%c{white}'
            display:drawText(sx - 12, y, disp[order[i]])
            if equipment[order[i]] then 
                if menuSelect == i then
                    colors = '%b{white}%c{black}'
                    display:write('XXXXXXXXXXXXXXX', sx - 1, y, ROT.Color.fromString('white'), ROT.Color.fromString('white'))
                    local desc = equipment[order[i]].desc
                    local width, lines = ROT.Text.measure(desc, 30)
                    drawFrame(59 + 15, sy - 1, 33, lines + 1)
                    display:drawText(77, sy, '%b{black}%c{white}'..desc, 30)
                end
                display:drawText(sx + 6 - math.floor(string.len(equipment[order[i]].name)/2), y, colors ..equipment[order[i]].name)
            end
            if order[i] == 'offhand' or order[i] == 'hands' then 
                y = y + 1
            end
            y = y + 1
        end
    elseif playerMenu == 'help' then 
        drawFrame(28, 1, 94, 33)
        --- Movement
        display:drawText(31, 3, '%b{black}%c{goldenrod}Movement')
        display:drawText(34, 5, '%b{black}%c{gold}y  k  u')
        display:drawText(35, 6, '%b{black}%c{gold}%c{grey}\\ | /  ')
        display:drawText(33, 7, '%b{black}%c{gold}h %c{grey}- %c{white}@ %c{grey}- %c{gold}l')
        display:drawText(35, 8, '%b{black}%c{gold}%c{grey}/ | \\  ')
        display:drawText(34, 9, '%b{black}%c{gold}b  j  n')
        --- Menus
        display:drawText(31, 11, '%b{black}%c{goldenrod}Menus')
        display:drawText(34, 13, '%b{black}%c{gold}i %c{grey}: %c{white}Inventory')
        display:drawText(34, 14, '%b{black}%c{gold}e %c{grey}: %c{white}Equipment')
        display:drawText(34, 15, '%b{black}%c{gold}m %c{grey}: %c{white}Messages')
        display:drawText(34, 16, '%b{black}%c{gold}? %c{grey}: %c{white}Help')
        --- Actions
        display:drawText(55, 3, '%b{black}%c{goldenrod}Actions')
        display:drawText(58, 6, '%b{black}%c{gold}f %c{grey}: %c{white}Fire Danmaku')
        display:drawText(58, 7, '%b{black}%c{gold}g %c{grey}: %c{white}Pickup Item')
        display:drawText(58, 8, '%b{black}%c{gold}> %c{grey}: %c{white}Descend')
        display:drawText(58, 9, '%b{black}%c{gold}< %c{grey}: %c{white}Ascend')
        display:drawText(58, 10, '%b{black}%c{gold}. %c{grey}: %c{white}Wait a Turn')
        display:drawText(58, 11, '%b{black}%c{gold}enter %c{grey}: %c{white}Use Object')
        --- lame
        display:drawText(99, 33, '%b{black}%c{white}Press any key to close')
    end
end

function drawHud()
    drawFrame(1, 1, 26, 43)
    drawPlayerMenu()
	--- character info
	display:drawText(4, 3, '%b{black}%c{white}'..player.name)
	display:drawText(4, 4, '%b{black}%c{silver}'..player.species .. ', ' ..player.class)
	display:drawText(4, 6, '%b{black}%c{gold}Level : ' .. '%c{white}'..player.level)
	display:drawText(4, 7, '%b{black}%c{gold}Exp   : ' .. '%c{white}'..player.exp)
	--- character status
    local cp = player.curPower 
    local mp = player.maxPower 
    if string.len(tostring(cp)) == 1 then 
        cp = tostring(cp) .. '.00'
    elseif string.len(tostring(cp)) == 3 then 
        cp = tostring(cp) .. '0'
    end
    if string.len(tostring(mp)) == 1 then 
        mp = tostring(mp) .. '.00'
    elseif string.len(tostring(mp)) == 3 then 
        mp = tostring(mp) .. '0'
    end
	display:drawText(4, 9, '%b{black}%c{tomato}Health : ' .. '%c{white}'..player.curHealth ..' / '..player.maxHealth)
	display:drawText(4, 10, '%b{black}%c{dodgerblue}Power  : ' .. '%c{white}'..cp ..' / '..mp)
	--- Atributes
	display:drawText(4, 12, '%b{black}%c{gold}Strength  : ' .. '%c{white}'..player.strength)
	display:drawText(4, 13, '%b{black}%c{gold}Knowledge : ' .. '%c{white}'..player.knowledge)
	display:drawText(4, 14, '%b{black}%c{gold}Spirit    : ' .. '%c{white}'..player.spirit)
	--- Combat stats
	display:drawText(4, 16, '%b{black}%c{goldenrod}Melee   : ')
    display:drawText(14, 16, '%b{black}%c{white}+' .. player.accuracy + getStat('accuracy') ..', '.. player.meleeDamageMin + getStat('meleeDamageMin') .. ' - ' .. player.meleeDamageMax + getStat('meleeDamageMax'))
	display:drawText(4, 17, '%b{black}%c{goldenrod}Danmaku : ')
    display:drawText(14, 17, '%b{black}%c{white}+' .. player.accuracy + getStat('accuracy') .. ', ' .. player.danmakuDamageMin + getStat('danmakuDamageMin') .. ' - ' .. player.danmakuDamageMax + getStat('danmakuDamageMax'))
	display:drawText(4, 18, '%b{black}%c{goldenrod}Defense : ')
    display:drawText(14, 18, '%b{black}%c{white}+' .. player.evasion + getStat('evasion') .. ', ' .. player.armorMin + getStat('armorMin') .. ' - ' .. player.armorMax + getStat('armorMax'))
	--- Location, date, yen
    local n = location[currentLocation].name
    if location[currentLocation].floors > 1 then 
        n = n .. ', ' .. currentFloor 
    end
    local t = string.sub(tostring(date.day), string.len(tostring(date.day) - 1))
    if t == '1' then
        t = 'st'
    elseif t == '2' then 
        t = 'nd'
    elseif t == '3' then 
        t = 'rd'
    else
        t = 'th'
    end
    if date.day > 10 and date.day < 20 then 
        t = 'th'
    end
    local min = date.minute 
    if date.minute < 10 then 
        min = '0' .. math.floor(date.minute) 
    else 
        min = math.floor(date.minute)
    end
    local hour = date.hour 
    if hour > 12 then 
        hour = hour - 12 
    end
    local suf = 'a.m.'
    if date.hour > 11 then 
        suf = 'p.m.'
    end
	display:drawText(4, 40, '%b{black}%c{white}'..n)
    display:drawText(4, 41, '%b{black}%c{white}'..calendar[date.month] ..' '.. date.day ..t .. ' %c{silver}' .. hour .. ':' .. min .. ' '.. suf)
	display:drawText(4, 42, '%b{black}%c{gold}' .. string.char(157) .. ' : ' .. '%c{white}'..player.yen)
    --- Objects and monsters in view
    local obs = { }
    local mons = { }
    local defs = mapLocationDefinition(location[currentLocation].mapdefinition)
    local y = 20
    if playerHunger <= 100 and playerHunger > 50 then 
        display:drawText(4, y, '%b{black}%c{white}Hungry')
        y = y + 2
    elseif playerHunger <= 50 and playerHunger > 10 then 
        display:drawText(4, y, '%b{black}%c{orange}Feint')
        y = y + 2
    elseif playerHunger <= 10 then 
        display:drawText(4, y, '%b{black}%c{red}Starving')
        y = y + 2
    end
    for x = 1, 95 do
        for y = 1, 34 do
            if map[x][y].val < 1 and (map[x][y].seen or DEBUGnoFog) and defs['floor'..1 - map[x][y].val].object then
                table.insert(obs, defs['floor'..1 - map[x][y].val])
            end
        end
    end
    for i = 1, # obs do 
        if y < 37 then
            display:write(obs[i].char, 4, y, obs[i].fg, obs[i].bg)
            display:drawText(6, y, '%b{black}%c{white}'..obs[i].object.desc)
            y = y + 1
        end
    end
    y = y + 1
    for i = 1, # actors do
        if (map[actors[i].x][actors[i].y].lit or DEBUGnoFog) and actors[i] ~= player then
            table.insert(mons, actors[i])
        end
    end
    for i = 1, # mons do
        if y < 37 then
            display:write(mons[i].char, 4, y, mons[i].fg, mons[i].bg)
            display:drawText(6, y, '%b{black}%c{white}'..mons[i].name)
            y = y + 1
        end
    end
    --- Tile editor
    if DEBUGeditor then
        local n = 'Tile #' ..DEBUGeditorTile.id 
        if DEBUGeditorTile.object then 
            n = DEBUGeditorTile.object.desc 
        end
        display:write(DEBUGeditorTile.char, 2, 1, DEBUGeditorTile.fg, DEBUGeditorTile.bg)
        display:drawText(4, 1, '%b{black}%c{white}'..n)
        display:drawText(4, 2, '%b{black}%c{white}'..DEBUGeditorX ..', '..DEBUGeditorY)
    end
end

function drawMap()
    local def = mapLocationDefinition(location[currentLocation].mapdefinition)
    for k,v in pairs(def) do
        if v.effect and v.effect.ondraw and draweffects then
            v.effect.ondraw(v)
        end
    end
    for x = 1, 95 do
        for y = 1, 34 do
            if map[x][y].seen or DEBUGnoFog then
                if not map[x][y].lit and not DEBUGnoFog then
                    if map[x][y].val > 0 then
                        display:write(def['wall'..map[x][y].val].char, x + 27, y, ROT.Color.interpolate(def['wall'..map[x][y].val].fg, ROT.Color.fromString('black'), 0.75), ROT.Color.interpolate(def['wall'..map[x][y].val].bg, ROT.Color.fromString('black'), 0.5))
                    else
                        display:write(def['floor'..1 - map[x][y].val].char, x + 27, y, ROT.Color.interpolate(def['floor'..1 - map[x][y].val].fg, ROT.Color.fromString('black'), 0.75), ROT.Color.interpolate(def['floor'..1 - map[x][y].val].bg, ROT.Color.fromString('black'), 0.5))
                    end
                else
                    if map[x][y].val > 0 then
                        display:write(def['wall'..map[x][y].val].char, x + 27, y, def['wall'..map[x][y].val].fg, def['wall'..map[x][y].val].bg)
                    else
                        display:write(def['floor'..1 - map[x][y].val].char, x + 27, y, def['floor'..1 - map[x][y].val].fg, def['floor'..1 - map[x][y].val].bg)
                    end
                end
            end
        end
    end
    if DEBUGeditorX > 0 and DEBUGeditorX < 96 and DEBUGeditorY > 0 and DEBUGeditorY < 35 and DEBUGeditor then
        display:write(DEBUGeditorTile.char, DEBUGeditorX + 27, DEBUGeditorY, ROT.Color.fromString('black'), ROT.Color.fromString('white'))
    end
    draweffects = false
end

function drawActors()
	for i = 1, # actors do
		local a = actors[i]
        if map[a.x][a.y].lit or DEBUGnoFog then
		  display:write(a.char, a.x + 27, a.y, a.fg, a.bg)
        end
	end
end

--[[ Danmaku Functions ]]--

function updateDanmaku(dt)
    for i = # danmaku, 1, -1 do 
        local d = danmaku[i] 
        local todelete = false
        d.delay = d.delay - dt 
        if d.delay <= 0 then
            d.t = d.t + dt  
            if d.t >= 0.03 then 
                redraw = true
                d.t = 0
                if not d.track then 
                    d.x = d.x + d.dx 
                    d.y = d.y + d.dy
                else
                    local a = math.atan2(d.track.y - player.y, d.track.x - player.x)
                    local dx = math.cos(a)
                    local dy = math.sin(a)
                    d.x = d.x + dx
                    d.y = d.y + dy
                end
                if d.x < 0 or d.y < 0 or d.x > 95 or d.y > 34 or map[math.floor(d.x)][math.floor(d.y)].val > 0 or map[math.ceil(d.x)][math.ceil(d.y)].val > 0 then 
                    todelete = true
                end
                for ii = # actors, 1, -1 do 
                    if (actors[ii].x == math.floor(d.x) and actors[ii].y == math.floor(d.y) and d.type ~= actors[ii].type) or (actors[ii].x == math.ceil(d.x) and actors[ii].y == math.ceil(d.y) and d.type ~= actors[ii].type) or (actors[ii].x == math.floor(d.x) and actors[ii].y == math.ceil(d.y) and d.type ~= actors[ii].type) or (actors[ii].x == math.ceil(d.x) and actors[ii].y == math.floor(d.y) and d.type ~= actors[ii].type) then 
                        actors[ii]:takeDanmakuDamage(d)
                        if not d.pierce then
                            todelete = true
                        end
                    end
                end
            end
        end
        if todelete then table.remove(danmaku, i) end
    end
end

function fireShotType(dx, dy)
    if player.name == 'Reimu Hakurei' then 
        fireHomingAmulet()
    elseif player.name == 'Marisa Kirisame' then 
        fireLaser(dx, dy, 1)
    elseif player.name == 'Alice Margatroid' then 
        fireLaser(dx, dy, 2)
    end
end

function fireLaser(dx, dy, t)
    local shots = math.floor((player.curPower))
    local char = '-'
    local color = 'lightskyblue'
    if t == 2 then 
        color = 'orange'
    end
    if dy ~= 0 and dx == 0 then 
        char = '|'
    elseif (dy == -1 and dx == -1) or (dy == 1 and dx == 1) then 
        char = string.char(92)
    elseif (dy == -1 and dx == 1) or (dy == 1 and dx == -1) then 
        char = '/'
    end
    if shots > 0 then 
        for i = 1, shots do 
            table.insert(danmaku, {type = 'player', pierce = true, track = mon, delay = (i)/20, x = player.x, y = player.y, t = 0, dx = dx, dy = dy, accuracy = player.accuracy + getStat('accuracy'), dmin = player.danmakuDamageMin + getStat('danmakuDamageMin'), dmax = player.danmakuDamageMax + getStat('danmakuDamageMax'), char = char, fg = ROT.Color.fromString(color), bg = ROT.Color.fromString('black')})
        end
    end
end

function fireHomingAmulet()
    local shots = math.floor((player.curPower))
    local mon = getClosestMonster(player.x, player.y)
    if mon and shots > 0 then 
        for i = 1, shots do 
            table.insert(danmaku, {type = 'player', track = mon, delay = (i)/20, x = player.x, y = player.y, t = 0, dx = 0, dy = 0, accuracy = player.accuracy + getStat('accuracy'), dmin = player.danmakuDamageMin + getStat('danmakuDamageMin'), dmax = player.danmakuDamageMax + getStat('danmakuDamageMax'), char = string.char(223), fg = ROT.Color.fromString('skyblue'), bg = ROT.Color.fromString('black')})
        end
    end
end

--[[ Item Functions ]]--

function getClosestMonster(x, y)
    local d = 1000
    local m = false
    for i = 1, # actors do 
        if actors[i] ~= player and actors[i].faction ~= player.faction then 
            if math.sqrt( (player.y - actors[i].y)^2 + (player.x - actors[i].x)^2 ) <= d then 
                m = actors[i] 
                d = math.sqrt( (player.y - actors[i].y)^2 + (player.x - actors[i].x)^2 )
            end
        end
    end
    return m
end

function getRandomItem()
    local t = 0
    local i = 0
    repeat
        for k,v in pairs(items) do
            t = t + 1
        end
        t = love.math.random(1, t)
        i = 0
        for k,v in pairs(items) do
            i = i + 1
            if i == t then 
                i = v 
                break 
            end
        end
    until type(i) == 'table' and (i.level or 1) <= player.level + love.math.random(1, 5)
    return tostring(i.type)    
end

function newItem(name)
    local i = { }
    if items[name] then
        for k,v in pairs(items[name]) do 
            i[k] = v
        end
        return i
    end
    return false
end

function dropItem(item, x, y)
    local sx, sy = x, y
    local r = 1
    local placed = false 
    repeat 
        local blocked = false 
        local newspace = true
        for i = 1, # itemsOnMap do 
            if (itemsOnMap[i].x == x and itemsOnMap[i].y == y) then 
                blocked = true 
            end
        end
        if (map[x][y].val > 0) then 
            blocked = true 
        end
        if blocked then 
            for xx = sx - r, sx + r do 
                for yy = sy - r, sy + r do
                    newspace = true
                    for i = 1, # itemsOnMap do 
                        if xx > 1 and yy > 1 and xx < 95 and yy < 34 then 
                            if (itemsOnMap[i].x == xx and itemsOnMap[i].y == yy) or map[xx][yy].val > 0 then 
                                newspace = false  
                            end
                        end
                    end
                    if newspace and xx > 1 and yy > 1 and xx < 95 and yy < 34 then 
                        x = xx 
                        y = yy 
                        break 
                    end
                end
                if newspace then break end 
            end
            r = r + 1
            if r > 100 then return end
        else 
            placed = true
            item.x = x 
            item.y = y
            table.insert(itemsOnMap, item)
            if x == player.x and y == player.y then 
                if item.onWalkOver then 
                    item.onWalkOver(item)
                end 
            end
        end
    until placed
end

function dropItemsAroundMap(min, max)
    for i = 1, love.math.random(min, max) do 
        local x = 0
        local y = 0
        repeat 
            x = love.math.random(1, 95)
            y = love.math.random(1, 34) 
        until map[x][y].val < 1
        dropItem(newItem(getRandomItem()), x, y)
    end
end

function getStat(stat)
    local val = 0
    local stack = true
    if stat == 'lightsource' then 
        stack = false 
    end
    for k,v in pairs(equipment) do
        if v then 
            if v.stats and v.stats[stat] then 
                if stack then 
                    val = val + v.stats[stat]
                else 
                    val = math.max(val, v.stats[stat])
                end
            end
        end
    end
    return val
end

--[[ Map Functions ]]--

function placeMonster(monName)
    if monsters[monName] then
        local placed = false 
        repeat 
            local x = love.math.random(3, 92)
            local y = love.math.random(3, 31)
            local blocked = false 
            if map[x][y].val < 1 and map[x][y].lit == false then 
                for i = 1, # actors do 
                    if actors[i].x == x and actors[i].y == y then 
                        blocked = true 
                    end
                end
                if not blocked then 
                    local a = actor:new(monsters[monName])
                    placed = true 
                    a.x = x 
                    a.y = y 
                    table.insert(actors, a)
                    scheduler:add(a, true)
                end
            end
        until placed
    end
end

function useDownstairs(x, y)
    if location[currentLocation].connections then
        for i = 1, # location[currentLocation].connections do
            local con = location[currentLocation].connections[i]
            if con and con.x == x and con.y == y and con.floor == currentFloor then
                mapChangeLocation(con.name, currentLocation, false)
                return
            end
        end
    end
    mapChangeFloors(1)
end

function useUpstairs(x, y)
    if currentFloor == 1 then
        if location[currentLocation].connections then
            for i = 1, # location[currentLocation].connections do
                local con = location[currentLocation].connections[i]
                if con and con.x == x and con.y == y and con.floor == currentFloor then
                    mapChangeLocation(con.name, currentLocation, false)
                    return 
                end
            end
        end
    end
    mapChangeFloors(-1)
end

function getDefinitationOfTile(x, y)
    if map[x][y].val > 0 then
        return mapLocationDefinition(location[currentLocation].mapdefinition)['wall'..map[x][y].val]
    else
        return mapLocationDefinition(location[currentLocation].mapdefinition)['floor'..1 - map[x][y].val]
    end
end

function mapLocationDefinition(name)

    return defs[name] or defs.overworld
end

function mapChangeFloors(d)
    if location[currentLocation] and location[currentLocation].generation then 
        saveMap()
        actors = { }
        itemsOnMap = { }
        scheduler:clear()
        currentFloor = currentFloor + d
        _G[location[currentLocation].generation](false, currentFloor - d)
        updateMessages()
        scheduler:add(player, true)
        table.insert(actors, player)
    end
end

function mapChangeLocation(loc, prev, spawn, dontsave)
    currentFloor = 1
    if location[loc] and location[loc].generation then
        if not dontsave then
            saveMap()
        end
        actors = { }
        itemsOnMap = { }
        scheduler:clear()
        currentLocation = loc
        _G[location[loc].generation](prev)
        if spawn and location[loc].spawn then
            revealMap()
            player.x = location[loc].spawn.x 
            player.y = location[loc].spawn.y 
        end
        if prev then
            for i = 1, # location[loc].connections do
                local con = location[loc].connections[i]
                if con.name == prev then
                    player.x = con.x 
                    player.y = con.y 
                end
            end
        end
        table.insert(actors, player)
        scheduler:add(player, true)
        computeFOV()
        updateMessages()
    end
end

function mapOverworld(prev, prevfloor)
    local chunk = true 
    if love.filesystem.exists("MAPgensokyo.lua") then
        chunk = love.filesystem.load("MAPgensokyo.lua")
        map, currentLocation = chunk()
        for x = 1, 95 do
            for y = 1, 34 do
                if map[x][y].seen then map[x][y].lit = true end
            end
        end
    else
        chunk = love.filesystem.load('/data/maps/gensokyo.lua')
        map = chunk()
    end
end

function mapDampCave(prev, prevfloor)
    local chunk = true
    if mapLoad("MAPdampCave"..currentFloor ..".lua") then
        if currentFloor == 1 then
            for x = 1, 95 do
                for y = 1, 34 do
                    if map[x][y].val == -1 then
                        location.dampcave.connections[1].x = x 
                        location.dampcave.connections[1].y = y 
                        player.x = x 
                        player.y = y
                    end
                end
            end
        end
        if prevfloor then 
            if prevfloor > currentFloor then 
                for x = 1, 95 do
                    for y = 1, 34 do
                        if map[x][y].val == -2 then
                            player.x = x 
                            player.y = y
                        end
                    end
                end
            else
                for x = 1, 95 do
                    for y = 1, 34 do
                        if map[x][y].val == -3 then
                            player.x = x 
                            player.y = y
                        end
                    end
                end
            end
        end
    else
        mapRogue(05, 34)
        if prev == 'gensokyo' then
            --- place stairs to gensokyo
            if currentFloor == 1 then
                local placed = false 
                repeat 
                    local x = love.math.random(3, 92)
                    local y = love.math.random(3, 31)
                    if map[x][y].val < 1 and map[x-1][y].val < 1 and map[x+1][y].val < 1 and map[x][y-1].val < 1 and map[x][y+1].val < 1 then
                        map[x][y].val = -1
                        player.x = x 
                        player.y = y
                        location.dampcave.connections[1].x = x 
                        location.dampcave.connections[1].y = y
                        placed = true
                    end
                until placed
            end
        end
        --- place downstairs
        if currentFloor < location[currentLocation].floors then 
            local placed = false 
            repeat 
                local x = love.math.random(3, 92)
                local y = love.math.random(3, 31)
                if map[x][y].val == 0 and map[x-1][y].val < 1 and map[x+1][y].val < 1 and map[x][y-1].val < 1 and map[x][y+1].val < 1 then
                    map[x][y].val = -2
                    if prevfloor and prevfloor > currentFloor then
                        player.x = x 
                        player.y = y
                    end
                    placed = true
                end
            until placed
        end
        --- place upstairs
        if currentFloor > 1 then 
            local placed = false 
            repeat 
                local x = love.math.random(3, 92)
                local y = love.math.random(3, 31)
                if map[x][y].val == 0 and map[x-1][y].val < 1 and map[x+1][y].val < 1 and map[x][y-1].val < 1 and map[x][y+1].val < 1 then
                    map[x][y].val = -3
                    if prevfloor and prevfloor < currentFloor then
                        player.x = x 
                        player.y = y
                    end
                    placed = true
                end
            until placed
        end
        dropItemsAroundMap(1, 2 + currentFloor)
        computeFOV()
        for i = 4 + currentFloor, love.math.random(9, 13) + currentFloor do 
            placeMonster(location[currentLocation].monsterTable[love.math.random(1, # location[currentLocation].monsterTable)])
        end
    end
    computeFOV() 
end

function mapAlicesHouse(prev, prevfloor) 
    local chunk = true 
    if not mapLoad("MAPalicesHouse.lua") then 
        chunk = love.filesystem.load('data/maps/aliceshouse.lua')
        map = chunk()
        if player.name == 'Alice Margatroid' then
            dropItem(newItem('threadedneedle'), 43, 12)
            dropItem(newItem('bluedress'), 43, 13)
            dropItem(newItem('dollmakersgloves'), 42, 13)
        else
            local m = actor:new(monsters.alicemargatroid)
            m.x = 45
            m.y = 15
            table.insert(actors, m)
            scheduler:add(m, true)
        end
    end
end

function mapMarisasHouse(prev, prevfloor)
    local chunk = true 
    if not mapLoad("MAPmarisasHouse.lua") then
        chunk = love.filesystem.load('data/maps/marisashouse.lua')
        map, currentLocation = chunk()
        if player.name == 'Marisa Kirisame' then
            dropItem(newItem('magicbroom'), 48, 14)
            dropItem(newItem('witchshat'), 47, 14)
            dropItem(newItem('witchsdress'), 48, 15)
            dropItem(newItem('uruchimai'), 49, 15)
            dropItem(newItem('uruchimai'), 49, 14)
            dropItem(newItem('uruchimai'), 47, 15)
            dropItem(newItem('magiclantern'), 49, 13)
        else 
            local m = actor:new(monsters.marisakirisame)
            m.x = 48
            m.y = 14
            table.insert(actors, m)
            scheduler:add(m, true)
        end
    end
end

function mapHakureiShrine(prev, prevfloor)
    local chunk = true 
    if not mapLoad("MAPhakureiShrine.lua") then
        chunk = love.filesystem.load('/data/maps/hakureishrine.lua')
        map, currentLocation = chunk()
        if player.name == 'Reimu Hakurei' then
            dropItem(newItem('onusa'), 56, 17)
            dropItem(newItem('whitehaori'), 56, 18)
            dropItem(newItem('redhakama'), 56, 19)
            dropItem(newItem('glowingomamori'), 55, 17)
            dropItem(newItem('uruchimai'), 55, 18)
            dropItem(newItem('uruchimai'), 55, 19)
            dropItem(newItem('uruchimai'), 55, 20)
        else
            local m = actor:new(monsters.reimuhakurei)
            m.x = 56
            m.y = 15
            table.insert(actors, m)
            scheduler:add(m, true)
        end
    end
end

function mapLoad(name)
    local mons = { }
    local is = { }
    if love.filesystem.exists(name) then
        chunk = love.filesystem.load(name)
        map, currentLocation, mons, is = chunk()
        if # mons > 0 then 
            for i = 1, # mons do 
                local a = actor:new(monsters[mons[i].name])
                a.x = mons[i].x
                a.y = mons[i].y 
                a.curHealth = mons[i].curHealth 
                a.faction = mons[i].faction
                scheduler:add(a, true)
                table.insert(actors, a)
            end
        end
        if # is > 0 then 
            for i = 1, # is do 
                local ii = newItem(is[i].name)
                dropItem(ii, is[i].x, is[i].y)
            end
        end
        return true
    end
    return false
end

function mapArena(width, height)
    local a = ROT.Map.Arena:new(95, 34)
    a:create(mapGenerationCallback)
end

function mapRogue(width, height)
    local a = ROT.Map.Rogue:new(95, 34)
    a:create(mapGenerationCallback)
end

function mapSetup(width, height)
    map = { }
    for x = 1, width do
        map[x] = { }
        for y = 1, height do
            map[x][y] = { }
        end
    end
end

function mapGenerationCallback(x, y, val)

    map[x][y] = {val = val, seen = false, lit = false}
end

function saveMap()
    --- filename
    local name = 'MAP'..currentLocation ..'.lua'
    if location[currentLocation].floors > 1 then 
        name = 'MAP'..currentLocation .. currentFloor ..'.lua'
    end
    --- save tile data
    tosave = 'local map = { } for x = 1, 95 do map[x] = { } for y = 1, 34 do map[x][y] = {val = 0, seen = false, lit = false} end end\n'
    tosave = tosave .. 'local location = \''..currentLocation ..'\'\n'
    for x = 1, 95 do
        for y = 1, 34 do
            tosave = tosave .. 'map['..x ..']['..y ..'] = {val = '..map[x][y].val ..', seen = '..tostring(map[x][y].seen) .. ', lit = false}\n'
        end
    end
    --- save monster data
    tosave = tosave .. 'local monsters = { }\n'
    for i = 1, # actors do 
        local a = actors[i]
        if a.type ~= 'player' then 
            tosave = tosave .. 'table.insert(monsters, {name = \'' .. a.type .. '\', x = ' .. a.x .. ', y = ' .. a.y .. ', curHealth = ' .. a.curHealth .. ', alert = ' .. tostring(a.alert) .. ', faction = \'' .. a.faction .. '\'})\n'
        end
    end
    --- save items 
    tosave = tosave .. 'local items = { }\n'
    for i = 1, # itemsOnMap do 
        local i = itemsOnMap[i]
        tosave = tosave .. 'table.insert(items, {name = \'' .. i.type .. '\', x = ' .. i.x .. ', y = ' .. i.y .. '})\n'
    end
    --- write save to file
    tosave = tosave .. 'return map, location, monsters, items\n'
    love.filesystem.write(name, tosave)
end

--[[ Date and Time ]]--

function advanceTime(t, dontmulti)
    if not dontmulti then
      t = t * 5
    end
    if currentLocation == 'gensokyo' then 
        t = 10
    end
    date.minute = date.minute + t
    if math.floor(date.minute) > math.floor(date.minute - t) then     
        for i = math.floor(date.minute - t), math.floor(date.minute) do
            playerRegenTimer = playerRegenTimer - 1 
            if playerRegenTimer < 1 then 
                player.curHealth = math.min(player.maxHealth, player.curHealth + 1)
                if player.species == 'Human' then
                    playerRegenTimer = math.max(1, 7 - player.strength / 3)
                else
                    playerRegenTimer = math.max(1, 7 - player.spirit / 3)
                end
            end
            playerHungerTimer = playerHungerTimer - 1 
            if playerHungerTimer < 1 then 
                playerHungerTimer = 1 + math.ceil(player.spirit / 3)
                if player.species == 'Human' then
                    playerHunger = playerHunger - 1
                    if playerHunger <= 100 and playerHunger >= 90 then 
                        table.insert(messages, 1, 'You are begining to feel hungry.')
                    elseif playerHunger <= 50 and playerHunger >= 40 then
                        table.insert(messages, 1, "You feel like you're starving!")
                    end
                end
            end
            if playerHunger < 10 then
                player.curHealth = math.max(player.curHealth - 1, 0)
            end
        end
    end
    if date.minute >= 60 then 
        date.hour = date.hour + 1 
        date.minute = 0 
        if date.hour == 24 then 
            date.day = date.day + 1 
            date.hour = 0
            if date.day > 30 then 
                date.day = 1
                date.month = date.month + 1
                if date.month > 4 then 
                    date.month = 1 
                end
            end
        end
    end
end

--[[ Messages ]]--

function updateMessages(dontcountturn)
    if # messages > 0 then
        local min = date.minute 
        if date.minute < 10 then 
            min = '0' .. math.floor(date.minute) 
        else 
            min = math.floor(date.minute)
        end
        local hour = date.hour 
        if hour > 12 then 
            hour = hour - 12 
        end
        local suf = 'a.m.'
        if date.hour > 11 then 
            suf = 'p.m.'
        end
        local t = tostring(hour) .. ':' .. tostring(min) .. ' ' .. suf 
        for i = # messages, 1, -1 do 
            table.insert(messagesDisp, 1, {msg = '<'.. t .. '> '.. messages[i], turn = 0})
        end
        messages = { }
    end
    if not dontcountturn then
        for i = 1, # messagesDisp do 
            messagesDisp[i].turn = messagesDisp[i].turn + 1
        end
    end
end

--[[ Save/Load Game ]]--

function loadGame()
    --- load player and location
    local chunk = love.filesystem.load('PLAYER.lua')
    local tempx, tempy = 0, 0
    local tempplayer = true
    local tempfloor = 0
    local inv = { }
    local eqp = { }
    tempplayer, currentLocation, tempfloor, date, inv, eqp, playerRegenTimer, playerHunger, playerHungerTimer = chunk()
    tempx, tempy = tempplayer.x, tempplayer.y
    player = actor:new(tempplayer)
    player.fg = ROT.Color.fromString(tempplayer.fg)
    player.bg = ROT.Color.fromString(tempplayer.bg)
    player.fgString = tempplayer.fg
    player.bgString = tempplayer.bg
    mapChangeLocation(currentLocation, false, false, true)
    if tempfloor > 1 then
        mapChangeFloors(tempfloor - 1)
    end
    player.x, player.y = tempx, tempy
    --- invetory 
    for i = 1, # inv do 
        table.insert(inventory, newItem(inv[i].name))
    end
    --- equipment
    for k,v in pairs(eqp) do
        equipment[k] = newItem(v.name)
    end
    --- load messages
    chunk = love.filesystem.load('MESSAGES.lua')
    messagesDisp = chunk()
    table.insert(messages, 1, 'You reawaken to a dream in dreary dark.')
    updateMessages()
    for x = 1, 95 do
        for y = 1, 34 do
            map[x][y].lit = false 
        end
    end
    computeFOV()
end

function saveGame()
    savePlayer()
    saveMap()
    saveMessages()
end

function saveMessages()
    local tosave = 'local messages = { }\n'
    for i = 1, # messagesDisp do
        tosave = tosave .. 'messages['..i ..'] = {msg = "'.. messagesDisp[i].msg .. '", turn = '.. messagesDisp[i].turn ..'}'
    end
    tosave = tosave .. 'return messages\n'
    love.filesystem.write('MESSAGES.lua', tosave)
end
    
function savePlayer()
    local tosave = 'local player = { }\ncurrentLocation = \'' .. currentLocation .. '\'\ncurrentFloor = ' .. currentFloor ..'\n'
    tosave = tosave .. 'date = {month = '.. date.month .. ', day = '.. date.day .. ', hour = '.. date.hour ..', minute = '..date.minute .. '}\n'
    tosave = tosave .. 'player[\''..'x' ..'\'] = ' .. player.x .. '\n'
    tosave = tosave .. 'player[\''..'y' ..'\'] = ' .. player.y .. '\n'
    tosave = tosave .. 'player[\''..'name' ..'\'] = \'' .. player.name .. '\'\n'
    tosave = tosave .. 'player[\''..'level' ..'\'] = ' .. player.level .. '\n'
    tosave = tosave .. 'player[\''..'exp' ..'\'] = ' .. player.exp .. '\n'
    tosave = tosave .. 'player[\''..'class' ..'\'] = \'' .. player.class .. '\'\n'
    tosave = tosave .. 'player[\''..'type' ..'\'] = \'' .. player.type .. '\'\n'
    tosave = tosave .. 'player[\''..'fg' ..'\'] = \'' .. player.fgString .. '\'\n'
    tosave = tosave .. 'player[\''..'bg' ..'\'] = \'' .. player.bgString .. '\'\n'
    tosave = tosave .. 'player[\''..'yen' ..'\'] = ' .. player.yen .. '\n'
    tosave = tosave .. 'player[\''..'strength' ..'\'] = ' .. player.strength .. '\n'
    tosave = tosave .. 'player[\''..'knowledge' ..'\'] = ' .. player.knowledge .. '\n'
    tosave = tosave .. 'player[\''..'spirit' ..'\'] = ' .. player.spirit .. '\n'
    tosave = tosave .. 'player[\''..'curHealth' ..'\'] = ' .. player.curHealth .. '\n'
    tosave = tosave .. 'player[\''..'maxHealth' ..'\'] = ' .. player.maxHealth .. '\n'
    tosave = tosave .. 'player[\''..'curPower' ..'\'] = ' .. player.curPower .. '\n'
    tosave = tosave .. 'player[\''..'maxPower' ..'\'] = ' .. player.maxPower .. '\n'
    tosave = tosave .. 'player[\''..'accuracy' ..'\'] = ' .. player.accuracy .. '\n'
    tosave = tosave .. 'player[\''..'meleeDamageMin' ..'\'] = ' .. player.meleeDamageMin .. '\n'
    tosave = tosave .. 'player[\''..'meleeDamageMax' ..'\'] = ' .. player.meleeDamageMax .. '\n'
    tosave = tosave .. 'player[\''..'danmakuDamageMax' ..'\'] = ' .. player.danmakuDamageMax .. '\n'
    tosave = tosave .. 'player[\''..'danmakuDamageMin' ..'\'] = ' .. player.danmakuDamageMin .. '\n'
    tosave = tosave .. 'player[\''..'evasion' ..'\'] = ' .. player.evasion .. '\n'
    tosave = tosave .. 'player[\''..'species' ..'\'] = \'' .. player.species .. '\'\n'
    tosave = tosave .. 'player[\''..'faction'..'\'] = \'' .. player.faction .. '\'\n'
    --- inventory 
    tosave = tosave .. 'local inventory = { }\n'
    for i = 1, # inventory do 
        tosave = tosave .. 'table.insert(inventory, {name = \'' .. inventory[i].type .. '\'})\n' 
    end
    --- equipment
    tosave = tosave .. 'local equipment = { }\n'
    for k,v in pairs(equipment) do
        if v then 
            tosave = tosave .. 'equipment[\''.. k .. '\'] = {name = \'' .. v.type .. '\'}\n'
        end
    end
    --- regen and hunger
    tosave = tosave .. 'local playerRegenTimer = ' .. playerRegenTimer .. '\n'
    tosave = tosave .. 'local playerHunger = ' .. playerHunger .. '\n'
    tosave = tosave .. 'local playerHungerTimer = ' .. playerHungerTimer .. '\n'
    --- save file
    tosave = tosave .. 'return player, currentLocation, currentFloor, date, inventory, equipment, playerRegenTimer, playerHunger, playerHungerTimer\n'
    love.filesystem.write('PLAYER.lua', tosave)
end

--[[ Field Of View ]]--

function computeFOV()
    local r = 100
    local sunset = {18, 19, 18, 17}
    if date.hour >= sunset[date.month] then 
        r = r - ((date.hour + (date.minute / 60)) - sunset[date.month]) * 40
        r = math.max(math.max(r, 4), getStat('lightsource'))
    elseif date.hour < 5 then
        r = math.max(4, getStat('lightsource'))
    elseif date.hour >= 5 and date.hour < 7 then 
        r = math.min(math.max(4 + (date.hour + (date.minute / 60) - 5) * 40, getStat('lightsource')), 100)
    end
    if currentLocation == 'gensokyo' then
        r = 2
    end
    if location[currentLocation].lightLevel then 
        r = math.max(location[currentLocation].lightLevel, getStat('lightsource'))
    end
    fieldOfView:compute(player.x, player.y, r, computeLightCallback)
end

function revealMap()
    for x = 1, 95 do
        for y = 1, 34 do
            map[x][y].seen = true 
        end
    end
end

function unlightMap()
    if currentLocation ~= 'gensokyo' then
        for x = 1, 95 do
            for y = 1, 34 do
                map[x][y].lit = false 
            end
        end
    end
end

function computeLightCallback(x, y, r, v)
    map[x][y].lit = r
    map[x][y].seen = true
end

function lightCallback(fov, x, y)
    if x < 1 or y < 1 or x > 95 or y > 34 then return false end
    local def = getDefinitationOfTile(x, y)
    if map[x][y].val > 0 and not (def.effect and def.effect.seeThru) then 
        return false 
    end
    return true
end