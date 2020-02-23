local dialogs = {}

function dialogs:new(path, loveframes, centerarea)

  local obj = {
    registered = {},
    loveframes = loveframes,
    centerarea = centerarea
  }
  setmetatable(obj, self)
  self.__index = self


  -- Register all dialogs at instance time
  local files = loveframes.GetDirectoryContents(path)
  local dialog

  for key, value in ipairs(files) do
    if value.extension == "lua" and value.name ~= "init.lua" then
      dialog = require(value.path.."/"..value.name)
      table.insert(obj.registered, dialog)
    end
  end

  return obj
end

function dialogs:execute(category, action, exchange)
  for key, value in ipairs(self.registered) do
    if value.category == category and value.action == action then
      value.execute(self.loveframes, self.centerarea, exchange)
    end
  end
end

return dialogs
