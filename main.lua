
-- Debug request detect
if arg[#arg] == "-debug" then
  require("mobdebug").start()
end

package.path = package.path .. ";libs/classic/?.lua;dialogs/?.lua;actions/?.lua;"

local loveframes
local dialogs -- Object with system dialogs
local actions
local uuid
local tween
local mainwin = {}
local confwin = {
  pwd = "",
  width = 800,
  height = 600,
  x = 0,
  y = 0,
  d = 1,
  theme = "Default",
  actionslist = { width = 150 },
  mario = { animation = true },
  open = { dir = "" },
  file = { input = "" }
}

function mainwin.CreateToolbar()

	local width = love.graphics.getWidth()
	local version = loveframes.version
	local stage = loveframes.stage

	mainwin.toolbar = loveframes.Create("panel")
	mainwin.toolbar:SetSize(width, 35)
	mainwin.toolbar:SetPos(0, 0)

	local info = loveframes.Create("text", mainwin.toolbar)
	info:SetPos(5, 3)
	info:SetText({
		{color = {0, 0, 0, 1}},
		"Love Frames (",
		{color = {.5, .25, 1, 1}}, "version " ..version.. " - " ..stage, 
		{color = {0,  0, 0, 1}}, ")\n",
		{color = {1, .4, 0, 1}}, "F1",
		{color = {0,  0, 0, 1}}, ": Toggle debug mode - ",
		{color = {1, .4, 0, 1}}, "F2",
		{color = {0,  0, 0, 1}}, ": Remove all objects"
	})

	mainwin.menu_trigger = loveframes.Create("button", mainwin.toolbar)
	mainwin.menu_trigger:SetPos(mainwin.toolbar:GetWidth() - 105, 5)
	mainwin.menu_trigger:SetSize(100, 25)
	mainwin.menu_trigger:SetText(i18n("menu_trigger_hide"))
	mainwin.menu_trigger.OnClick = function()
	  mainwin.ToggleActionsList()
	end

	mainwin.skinslist = loveframes.Create("multichoice", toolbar)
	mainwin.skinslist:SetPos(mainwin.toolbar:GetWidth() - confwin.actionslist.width, 5)
	mainwin.skinslist:SetWidth(140)
	mainwin.skinslist:SetChoice(i18n("choose_a_skin"))
	mainwin.skinslist.OnChoiceSelected = function(object, choice)
		loveframes.SetActiveSkin(choice)
	end

	local skins = loveframes.skins
	for k, v in pairs(skins) do
		mainwin.skinslist:AddChoice(v.name)
	end
	mainwin.skinslist:Sort()
end

function mainwin.CreateActionsList()
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()

	mainwin.actionslist = loveframes.Create("list")
	mainwin.actionslist:SetPos(width - confwin.actionslist.width, 35)
  mainwin.actionslist.lastWidth = confwin.actionslist.width
	mainwin.actionslist:SetSize(confwin.actionslist.width, height - 35)
	mainwin.actionslist:SetPadding(5)
	mainwin.actionslist:SetSpacing(5)
	mainwin.actionslist.toggled = true

	mainwin.tween_open  = tween.new(1, mainwin.actionslist, {x = (width - confwin.actionslist.width)}, "outBounce")
	mainwin.tween_close = tween.new(1, mainwin.actionslist, {x = (width - 5)}, "outBounce")
  mainwin.tween_move = tween.new(1, mainwin.actionslist, {x = (width - 5)}, "outBounce")

	for key, value in pairs(actions.registered) do
    local panelheight = 0
    local category = loveframes.Create("collapsiblecategory")
    category:SetText(key)
    local panel = loveframes.Create("panel")
    panel.Draw = function() end
    mainwin.actionslist:AddItem(category)
    for k, v in pairs(value) do
	    local button = loveframes.Create("button", panel)
		  button:SetWidth(confwin.actionslist.width - 20)
		  button:SetPos(0, panelheight)
		  button:SetText(v.id)
		  button.OnClick = function()
		  	v:execute(key, v.id)
		  end
      panelheight = panelheight + 30
      panel:SetHeight(panelheight)
      category:SetObject(panel)
      category:SetOpen(true)
    end
	end
end

function mainwin.ToggleActionsList()
	local toggled = mainwin.actionslist.toggled
  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()

	if not toggled then
		mainwin.actionslist.toggled = true
		mainwin.tween = mainwin.tween_open
    mainwin.actionslist.lastWidth = 250
		mainwin.menu_trigger:SetText(i18n("menu_trigger_hide"))
	else
		mainwin.actionslist.toggled = false
		mainwin.tween = mainwin.tween_close
    mainwin.actionslist.lastWidth = 5
		mainwin.menu_trigger:SetText(i18n("menu_trigger_show"))
	end
	mainwin.tween:reset()
end


function love.load()
  local dir = love.filesystem.getSaveDirectory( )
  mainwin.cursor = love.mouse.newCursor("resources/normal.png", 0, 0)
	local font = love.graphics.newFont(12)
	love.graphics.setFont(font)
  i18n = require("libs/i18n")
	loveframes = require("libs/loveframes")
  lunajson = require("libs/lunajson")
	tween = require("libs/tween")
  acca = require("libs/acca")
  uuid = require("libs/uuid")
  lfs = require("libs/plfs"):new()

  -- Window custom configuration
  local str = love.filesystem.read("win.json")
  if str then
    confwin = lunajson.decode(str)
  else
    str = nil
    confwin.open.dir = love.filesystem.getWorkingDirectory()
    confwin.open.dir = lfs:adaptPath(confwin.open.dir)
  end

  confwin.pwd = love.filesystem.getWorkingDirectory()
  mainwin.cursor = {normal = nil}
  loveframes.config["ENABLE_SYSTEM_CURSORS"] = false
  mainwin.cursor.normal = love.mouse.newCursor("resources/normal.png", 0, 0)
  love.mouse.setCursor(mainwin.cursor.normal)
  love.window.setMode(confwin.width, confwin.height, {resizable = true, fullscreen = false, centered = false})
  love.window.setPosition(confwin.x, confwin.y, confwin.d)

  -- Progress bar
  mainwin.mario = newCharacter("resources/sprites","mario", "png", 0.1, "Stance")
  mainwin.mario:setDirection("Forward")
  mainwin.mario:setAction("Walking")
  mainwin.mario.x = 0
  mainwin.mario.jump = false
  mainwin.mario.xjump = love.math.random()

  -- Languages
  i18n.loadFile('resources/lang/en.lua', love.filesystem.load) -- load English language file
  i18n.loadFile('resources/lang/sp.lua', love.filesystem.load) -- load Spanish language file
  i18n.setLocale('en')

	-- table to store available actions
	mainwin.actions = {}
	mainwin.actions[1] = {category_title = i18n("menu_file"), registered = {}}
  mainwin.actions[2] = {category_title = i18n("menu_conf"), registered = {}}
  mainwin.actions[3] = {category_title = i18n("menu_addons"), registered = {}}
	mainwin.actions[4] = {category_title = i18n("menu_help"), registered = {}}

	mainwin.actionslist = nil
	mainwin.actionsbutton = nil
	mainwin.tween = nil
	mainwin.centerarea = {5, 40, 540, 555}
  mainwin.quit = false

  local exchange = { confwin = confwin, lfs = lfs , lunajson = lunajson }
  dialogs = require("dialogs"):new(loveframes, mainwin.centerarea, exchange)
  actions = require("actions"):new(loveframes, mainwin.centerarea, dialogs, exchange)

	mainwin.image = love.graphics.newImage("resources/background.png")
	mainwin.image:setWrap("repeat", "repeat")

	-- create mainwin gui
	mainwin.CreateToolbar()
  mainwin.CreateActionsList()
end

function love.update(dt)
  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()
	loveframes.update(dt)
  mainwin.toolbar:SetSize(width, 35)
  mainwin.skinslist:SetPos(width - confwin.actionslist.width - 105, 5)
  mainwin.menu_trigger:SetPos(width - 105, 5)
  mainwin.centerarea = {5, 40, width, height}
  if mainwin.lastHeight ~= height then
    mainwin.actionslist:SetSize(confwin.actionslist.width, height - 35)
    mainwin.mario.y = height - 32
  end
  if mainwin.lastWidth ~= width then
    mainwin.tween_open:responsive({x = width - confwin.actionslist.width})
    mainwin.tween_close:responsive({x = width - 5})
    mainwin.tween_move:responsive({x = width - mainwin.actionslist.lastWidth})
    mainwin.tween = mainwin.tween_move
    mainwin.tween:reset()
    mainwin.bgquad = love.graphics.newQuad(0, 0, width, height, mainwin.image:getWidth(), mainwin.image:getHeight())
    mainwin.bgimage = mainwin.image
  end
  if mainwin.tween then
		if mainwin.tween:update(dt) then mainwin.tween = nil end
	end

  if confwin.mario.animation == true then
    local mario = mainwin.mario
    mario.x = mario.x + 100 * dt
    local des = width - mario.x + 26
    if des < 0 then
      mario.x = des
      mario.xjump = love.math.random(0, width)
    end
    if mario.x >= mario.xjump and mario.x < mario.xjump * 1.2 and mario.jump == false then
      mario.jump = true
      mario:setAction("Jump")
    end
    if mario.jump == true then
      local dy = math.sin(2 * math.pi * (love.timer.getTime()))
      mario.y = mario.y - 5 * dy
      if mario.y > (height - 36) then
        mario.y = height - 32
        mario.jump = false
        mario:setAction("Walking")
      end
    end
    mario:update(dt)
  end

  mainwin.lastWidth = width
  mainwin.lastHeight = height
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(mainwin.bgimage, mainwin.bgquad, 0, 0)
  if confwin.mario.animation == true then
    mainwin.mario:draw(mainwin.mario.x, mainwin.mario.y, 0, 1, 1)
  end
	loveframes.draw()
end

function love.mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
	local menu = loveframes.hoverobject and loveframes.hoverobject.menu_trigger
	if menu and button == 2 then
		menu:SetPos(x, y)
		menu:SetVisible(true)
		menu:MoveToTop()
	end
end

function love.mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

function love.wheelmoved(x, y)
	loveframes.wheelmoved(x, y)
end

function love.keypressed(key, isrepeat)
	loveframes.keypressed(key, isrepeat)
	if key == "f1" then
		local debug = loveframes.config["DEBUG"]
		loveframes.config["DEBUG"] = not debug
	elseif key == "f2" then
		loveframes.RemoveAll()
		mainwin.CreateToolbar()
		mainwin.CreateActionsList()
		--demo.ToggleActionsList()
	end
end

function love.keyreleased(key)
	loveframes.keyreleased(key)
end

function love.textinput(text)
	loveframes.textinput(text)
end

function love.quit()
  return true
end
