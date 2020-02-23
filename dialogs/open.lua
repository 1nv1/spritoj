local dialog = {}

dialog.action = "open"
dialog.category = "file"

local function listLoad(loveframes, list, files)
  local lfs = love.filesystem
  local button
  list:Clear()
  button = loveframes.Create("button")
  button:SetText("..")
  button.OnClick = function(object)
    listLoad(loveframes, list, lfs.getDirectoryItems(".."))
  end
  list:AddItem(button)
  for key, value in ipairs(files) do
    button = loveframes.Create("button")
    button:SetText(value)
    button.OnClick = function(object)
      return object:GetText()
    end
    list:AddItem(button)
  end
end

function dialog.execute(loveframes, centerarea, exchange)

  local lfs = love.filesystem
  local ex = exchange

  if ex.trigger ~= nil then ex.trigger.enabled = false end

  local frame = loveframes.Create("frame")
  local width = 400
  local height = 300
	frame:SetName("Open file")
	frame:SetSize(width, height)
	frame:CenterWithinArea(unpack(centerarea))

	local listOfFiles = loveframes.Create("list", frame)
	listOfFiles:SetPos(5, 30)
  listOfFiles:SetSize(width - 10, height - 35)
	listOfFiles:SetPadding(5)
	listOfFiles:SetSpacing(5)
  local files = lfs.getDirectoryItems("")
  local item = listLoad(loveframes, listOfFiles, files)

  frame.OnClose = function(object)
    if ex.trigger ~= nil then ex.trigger.enabled = true end
  end

end

return dialog
