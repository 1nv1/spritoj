local action = {}
action.title = i18n("menu_help_exit")
action.category = i18n("menu_help")

function action.func(loveframes, centerarea)

  local frame = loveframes.Create("frame")
	frame:SetName(i18n("menu_help_exit_msg"))
  frame:CenterWithinArea(unpack(centerarea))
  frame:SetSize(200, 80)

  local button = loveframes.Create("button", frame)
	button:SetText("Yes")
	button:SetWidth(120)
	button:Center()
  button.OnClick = function(object, x, y)
    os.exit()
	end

end

return action
