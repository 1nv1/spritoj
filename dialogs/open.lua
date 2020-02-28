local Object = require("dialog"):new()
local dialog_open = Object:extend()


function dialog_open:new(loveframes, centerarea, exchange)
  self.action = "open"
  self.category = "file"
  self.loveframes = loveframes
  self.centerarea = centerarea
  self.exchange = exchange
  return self
end

function dialog_open:execute(title)
  local exchange = self.exchange
  local loveframes = self.loveframes
  local centerarea = self.centerarea

  if exchange.trigger ~= nil then exchange.trigger.enabled = false end

  frame = loveframes.Create("frame")
	frame:SetName(title)
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
  local item = self:showFolderItems(listOfFiles, files, exchange)

  frame.OnClose = function(object)
    if exchange.trigger ~= nil then exchange.trigger.enabled = true end
  end

end

return dialog_open
