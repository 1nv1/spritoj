local Object = require("classic")
local actions = Object:extend()

function actions:new(loveframes, centerarea, dialogs, exchange, path)

  self.loveframes = loveframes
  self.centerarea = centerarea
  self.dialogs = dialogs
  self.exchange = exchange
  self.path = path or "actions"
  self.registered = {}

  -- Register all dialogs at instance time
  local files = loveframes.GetDirectoryContents(self.path)
  local action
  local ids

  for key, value in ipairs(files) do
    if value.extension == "lua" and value.name ~= "actions" and value.name ~= "action" then
      local file = value.name
      local args = {
        loveframes = self.loveframes,
        centerarea = self.centerarea,
        dialogs = self.dialogs,
        exchange = self.exchange
      }
      action = require(file):new(args)
      if not self.registered[action.category] then self.registered[action.category] = {} end
      self.registered[action.category][action.id] = action
    end
  end

  return self
end

function actions:execute(category, id)
  local action = self.registered[category][id]
  action:execute()
end

return actions
