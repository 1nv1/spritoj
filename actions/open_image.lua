local Object = require("action")
local open_image = Object:extend()

function open_image:new(args)
  self.id = "Open"
  self.category = "File"
  self.loveframes = args.loveframes
  self.centerarea = args.centerarea
  self.dialogs = args.dialogs
  self.exchange = args.exchange
  return self
end

function open_image:execute()
  local loveframes = self.loveframes
  local centerarea = self.centerarea
  local exchange = self.exchange
  local dialogs = self.dialogs
  local confwin = self.exchange.confwin

  if exchange.trigger ~= nil then
    exchange.trigger.enabled = false
  end

  if dialogs:execute("file", "open", i18n("menu_file_open_image")) then
    local frame = loveframes.Create("frame")
    frame:SetName(i18n("menu_file_image"))
    frame:SetSize(400, 130)
    frame:CenterWithinArea(unpack(centerarea))
  end

  frame.OnClose = function(object)
    if exchange.trigger ~= nil then
      exchange.trigger.enabled = true
    end
  end

end

return open_image
