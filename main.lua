
local loveframes
local tween
local mainwin = {}

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
	mainwin.skinslist:SetPos(mainwin.toolbar:GetWidth() - 250, 5)
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

function mainwin.RegisterActions(action)
	local actions = mainwin.actions
	local category = action.category

	for k, v in ipairs(actions) do
		if v.category_title == category then
			table.insert(actions[k].registered, action )
		end
	end
end

function mainwin.CreateActionsList()
	local actions = mainwin.actions
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()

	mainwin.actionslist = loveframes.Create("list")
	mainwin.actionslist:SetPos(width - 250, 35)
  mainwin.actionslist.lastWidth = 250
	mainwin.actionslist:SetSize(250, height - 35)
	mainwin.actionslist:SetPadding(5)
	mainwin.actionslist:SetSpacing(5)
	mainwin.actionslist.toggled = true

	mainwin.tween_open  = tween.new(1, mainwin.actionslist, {x = (width - 250)}, "outBounce")
	mainwin.tween_close = tween.new(1, mainwin.actionslist, {x = (width - 5)}, "outBounce")
  mainwin.tween_move = tween.new(1, mainwin.actionslist, {x = (width)}, "outBounce")

	for k, v in ipairs(actions) do
		local panelheight = 0
		local category = loveframes.Create("collapsiblecategory")
		category:SetText(v.category_title)
		local panel = loveframes.Create("panel")
		panel.Draw = function() end
		mainwin.actionslist:AddItem(category)
		for key, value in ipairs(v.registered) do
			local button = loveframes.Create("button", panel)
			button:SetWidth(210)
			button:SetPos(0, panelheight)
			button:SetText(value.title)
			button.OnClick = function()
				value.func(loveframes, mainwin.centerarea)
				mainwin.current = value
			end
			panelheight = panelheight + 30
		end
		panel:SetHeight(panelheight)
		category:SetObject(panel)
		category:SetOpen(true)
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
  -- Debug request detect
  if arg[#arg] == "-debug" then require("mobdebug").start() end

  mainwin.cursor = love.mouse.newCursor("resources/normal.png", 0, 0)
	local font = love.graphics.newFont(12)
	love.graphics.setFont(font)
  i18n = require("gui/i18nlua/i18n")
	loveframes = require("gui/LoveFrames/loveframes")
	tween = require("tween")

  mainwin.cursor = {normal = nil}
  loveframes.config["ENABLE_SYSTEM_CURSORS"] = false
  mainwin.cursor.normal = love.mouse.newCursor("resources/normal.png", 0, 0)
  love.mouse.setCursor(mainwin.cursor.normal)

  -- Languages
  i18n.loadFile('gui/lang/en.lua') -- load English language file
  i18n.loadFile('gui/lang/sp.lua') -- load Spanish language file
  i18n.setLocale('en')

	-- table to store available actions
	mainwin.actions = {}
	mainwin.actions[1] = {category_title = i18n("menu_file"), registered = {}}
	mainwin.actions[2] = {category_title = i18n("menu_help"), registered = {}}

	mainwin.actionslist = nil
	mainwin.actionsbutton = nil
	mainwin.tween = nil
	mainwin.centerarea = {5, 40, 540, 555}
  mainwin.quit = false

	local files = loveframes.GetDirectoryContents("actions")
	local action
	for k, v in ipairs(files) do
		if v.extension == "lua" then
			action = require(v.path.."/"..v.name)
			mainwin.RegisterActions(action)
		end
	end

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
  mainwin.skinslist:SetPos(width - 250, 5)
  mainwin.menu_trigger:SetPos(width - 105, 5)
  mainwin.centerarea = {5, 40, width, height}
  if mainwin.lastHeight ~= height then
    mainwin.actionslist:SetSize(250, height - 35)
  end
  if mainwin.lastWidth ~= width then
    mainwin.tween_open:responsive({x = width - 250})
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
  mainwin.lastWidth = width
  mainwin.lastHeight = height
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(mainwin.bgimage, mainwin.bgquad, 0, 0)
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
