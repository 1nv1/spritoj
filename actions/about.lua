local action = {}
action.title = i18n("menu_help_about")
action.category = i18n("menu_help")

local message = i18n("menu_help_about_msg")..[[

  ----
Website: https://github.com/1nv1/Spritoj/
]]

function action.func(loveframes, centerarea)

	local frame = loveframes.Create("frame")
	frame:SetName(i18n("menu_help_about"))
	frame:SetSize(400, 130)
	frame:CenterWithinArea(unpack(centerarea))

	local list1 = loveframes.Create("list", frame)
	list1:SetPos(5, 30)
	list1:SetSize(390, 90)
	list1:SetPadding(5)
	list1:SetSpacing(5)

	local text1 = loveframes.Create("text")
	text1:SetLinksEnabled(true)
	text1:SetDetectLinks(true)
	text1:SetText(message)
	text1:SetShadowColor(.8, .8, .8, 1)
	list1:AddItem(text1)

end

return action
