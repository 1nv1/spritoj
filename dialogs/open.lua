local dialog = {}

dialog.action = "open"
dialog.category = "file"
local frame

local function listLoad(loveframes, list, files, exchange)

  local button
  list:Clear()
  button = loveframes.Create("button")
  button:SetText(exchange.confwin.open.dir.."..")
  button.OnClick = function(object)
    local pathsep = exchange.lfs.pathsep
    exchange.confwin.open.dir = exchange.confwin.open.dir:gsub(pathsep .. '[^' .. pathsep .. ']+$', '')
    local files = exchange.lfs:getDirectoryItems(exchange.confwin.open.dir)
    listLoad(loveframes, list, files, exchange)
  end
  list:AddItem(button)
  for key, value in ipairs(files) do
    local button = loveframes.Create("button")
    button:SetText(value.name)
    button.path = value.path
    if value.mode == "file" then
      button:SetImage("resources/file.png")
      button.OnClick = function(object)
        frame:Remove()
        return nil
      end
    end
    if value.mode == "directory" then
      button:SetImage("resources/folder.png")
      button.path = value.path
      button.OnClick = function(object)
        exchange.confwin.open.dir = object.path
        local files = exchange.lfs:getDirectoryItems(exchange.confwin.open.dir)
        listLoad(loveframes, list, files, exchange)
      end
    end
    list:AddItem(button)
  end
end

function dialog.execute(loveframes, centerarea, exchange)

  if exchange.trigger ~= nil then exchange.trigger.enabled = false end

  frame = loveframes.Create("frame")
	frame:SetName("Open file")
  frame:SetSize(400, 300)
  frame:CenterWithinArea(unpack(centerarea))
  frame:SetResizable(true)
	frame:SetMaxWidth(800)
	frame:SetMaxHeight(600)
	frame:SetMinWidth(400)
	frame:SetMinHeight(300)

	local listOfFiles = loveframes.Create("list", frame)
	listOfFiles:SetPos(5, 30)
  listOfFiles:SetPadding(5)
	listOfFiles:SetSpacing(5)
  listOfFiles:SetSize(frame:GetWidth() - 10, frame:GetHeight() - 35)
	listOfFiles.Update = function(object)
    listOfFiles:SetPos(5, 30)
    listOfFiles:SetPadding(5)
    listOfFiles:SetSpacing(5)
		object:SetSize(frame:GetWidth() - 10, frame:GetHeight() - 35)
	end
  local files = exchange.lfs:getDirectoryItems(exchange.confwin.open.dir)
  local item = listLoad(loveframes, listOfFiles, files, exchange)

  frame.OnClose = function(object)
    if exchange.trigger ~= nil then exchange.trigger.enabled = true end
  end

end

return dialog
