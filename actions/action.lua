local Object = require("classic")
local action = Object:extend()

function action:new()
  return self
end

return action
