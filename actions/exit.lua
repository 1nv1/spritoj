local action = {}
action.title = i18n("menu_file_exit")
action.category = i18n("menu_file")

function action.func(loveframes, centerarea, lunajson, confwin, button)

  local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
  confwin.x, confwin.y, confwin.d = love.window.getPosition()
  love.window.setMode(width, height, {resizable = false, fullscreen = false, centered = false})

  local frame = loveframes.Create("frame")
	frame:SetName(i18n("menu_file_exit_msg"))
  frame:CenterWithinArea(unpack(centerarea))
  frame:SetSize(200, 80)

  local button = loveframes.Create("button", frame)
	button:SetText("Yes")
	button:SetWidth(120)
	button:SetPos(40, 40)
  button:GetParent():SetModal(true)

  button.OnClick = function(object, x, y)
    local success
    local message
    local path = love.filesystem.getSource()
    confwin.width = width
    confwin.height = height
    local data = lunajson.encode(confwin)
    success, message = love.filesystem.write("win.json", data)
    os.exit()
  end

  frame.OnClose = function(object)
    love.window.setMode(width, height, {resizable = true, fullscreen = false, centered = false})
    love.window.setPosition(confwin.x, confwin.y, confwin.d)
  end

end

return action
