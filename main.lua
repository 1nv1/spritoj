
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

	spritoj.menu_trigger = loveframes.Create("button", spritoj.toolbar)
	spritoj.menu_trigger:SetPos(spritoj.toolbar:GetWidth() - 105, 5)
	spritoj.menu_trigger:SetSize(100, 25)
	spritoj.menu_trigger:SetText(i18n("menu_trigger_hide"))
	spritoj.menu_trigger.OnClick = function()
	  spritoj.ToggleActionsList()
	end

	spritoj.skinslist = loveframes.Create("multichoice", toolbar)
	spritoj.skinslist:SetPos(spritoj.toolbar:GetWidth() - 250, 5)
	spritoj.skinslist:SetWidth(140)
	spritoj.skinslist:SetChoice(i18n("choose_a_skin"))
	spritoj.skinslist.OnChoiceSelected = function(object, choice)
		loveframes.SetActiveSkin(choice)
	end

	local skins = loveframes.skins
	for k, v in pairs(skins) do
		spritoj.skinslist:AddChoice(v.name)
	end
	spritoj.skinslist:Sort()
end

function spritoj.RegisterActions(action)
	local actions = spritoj.actions
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

	local font = love.graphics.newFont(12)
	love.graphics.setFont(font)
  i18n = require("gui/i18nlua/i18n")
	loveframes = require("gui/LoveFrames/loveframes")
	tween = require("tween")

  -- Languages
  i18n.loadFile('gui/lang/en.lua') -- load English language file
  i18n.loadFile('gui/lang/sp.lua') -- load Spanish language file
  i18n.setLocale('en')

	-- table to store available actions
	spritoj.actions = {}
	spritoj.actions[1] = {category_title = i18n("menu_file"), registered = {}}
	spritoj.actions[2] = {category_title = i18n("menu_help"), registered = {}}

	spritoj.actionslist = nil
	spritoj.actionsbutton = nil
	spritoj.tween = nil
	spritoj.centerarea = {5, 40, 540, 555}
  spritoj.quit = false

	local files = loveframes.GetDirectoryContents("actions")
	local action
	for k, v in ipairs(files) do
		if v.extension == "lua" then
			action = require(v.path.."/"..v.name)
			spritoj.RegisterActions(action)
		end
	end

	spritoj.image = love.graphics.newImage("resources/background.png")
	spritoj.image:setWrap("repeat", "repeat")

	-- create spritoj gui
	spritoj.CreateToolbar()
  spritoj.CreateActionsList()
end

function love.update(dt)
  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()
	loveframes.update(dt)
  spritoj.toolbar:SetSize(width, 35)
  spritoj.skinslist:SetPos(width - 250, 5)
  spritoj.menu_trigger:SetPos(width - 105, 5)
  spritoj.centerarea = {5, 40, width, height}
  if spritoj.lastHeight ~= height then
    spritoj.actionslist:SetSize(250, height - 35)
  end
  if spritoj.lastWidth ~= width then
    spritoj.tween_open:responsive({x = width - 250})
    spritoj.tween_close:responsive({x = width - 5})
    spritoj.tween_move:responsive({x = width - spritoj.actionslist.lastWidth})
    spritoj.tween = spritoj.tween_move
    spritoj.tween:reset()
    spritoj.bgquad = love.graphics.newQuad(0, 0, width, height, spritoj.image:getWidth(), spritoj.image:getHeight())
    spritoj.bgimage = spritoj.image
  end
  if spritoj.tween then
		if spritoj.tween:update(dt) then spritoj.tween = nil end
	end
  spritoj.lastWidth = width
  spritoj.lastHeight = height
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(spritoj.bgimage, spritoj.bgquad, 0, 0)
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
