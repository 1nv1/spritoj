local action = {}
action.title = i18n("menu_help_exit")
action.category = i18n("menu_help")

function action.func(loveframes, centerarea)
  local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
  love.window.setMode(width, height, {resizable = false})

  local frame = loveframes.Create("frame")
	frame:SetName(i18n("menu_help_exit_msg"))
  frame:CenterWithinArea(unpack(centerarea))
  frame:SetSize(200, 80)

  local button = loveframes.Create("button", frame)
	button:SetText("Yes")
	button:SetWidth(120)
	button:SetPos(40, 40)
  button:GetParent():SetModal(true)
  button.OnClick = function(object, x, y)
    os.exit()
  end
  frame.OnClose = function(object)
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    love.window.setMode(width, height, {resizable = true})
  end
end

return action
