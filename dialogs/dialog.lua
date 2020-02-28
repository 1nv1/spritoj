local Object = require("classic")
local dialog = Object:extend()

function dialog:new()
  return self
end

function dialog:showFolderItems(list, files, exchange)
  local loveframes = self.loveframes
  local button
  list:Clear()
  button = loveframes.Create("button")
  button:SetText(exchange.confwin.open.dir.."..")
  button.OnClick = function(object)
    local pathsep = exchange.lfs.pathsep
    exchange.confwin.open.dir = exchange.confwin.open.dir:gsub(pathsep .. '[^' .. pathsep .. ']+$', '')
    local files = exchange.lfs:getDirectoryItems(exchange.confwin.open.dir)
    self:showFolderItems(list, files, exchange)
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
        self:showFolderItems(list, files, exchange)
      end
    end
    list:AddItem(button)
  end
end

return dialog
