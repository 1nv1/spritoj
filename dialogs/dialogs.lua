local Object = require("classic")
local dialogs = Object:extend()

function dialogs:new(loveframes, centerarea, exchange, path)

  self.registered = {}
  self.loveframes = loveframes
  self.centerarea = centerarea
  self.exchange = exchange
  self.path = path or "dialogs"

  -- Register all dialogs at instance time
  local files = loveframes.GetDirectoryContents(self.path)
  local dialog

  for key, value in ipairs(files) do
    if value.extension == "lua" and value.name ~= "dialogs" and value.name ~= "dialog" then
      local file = value.name
      dialog = require(file):new(self.loveframes, self.centerarea, self.exchange)
      self.registered[dialog.category..":"..dialog.action] = dialog
    end
  end

  return self
end

function dialogs:execute(category, action, title)
  self.registered[category..":"..action]:execute(title)
end

return dialogs
