local action = {}

action.title = i18n("menu_file_open_image")
action.category = i18n("menu_file")

function action.func(loveframes, centerarea, lunajson, confwin, trigger, dialogs)

  if trigger ~= nil then trigger.enabled = false end

  local frame = loveframes.Create("frame")
	frame:SetName(i18n("menu_file_open_image"))
	frame:SetSize(400, 130)
	frame:CenterWithinArea(unpack(centerarea))
  dialogs:execute("file", "open")

  frame.OnClose = function(object)
    if trigger ~= nil then trigger.enabled = true end
  end

end

return action
