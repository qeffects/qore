local path = (...):gsub(".util", "")
---@type SimpleClass
local SimpleClass = require(path..".util.simpleClass")
---@type uuid
local uuid = require(path..".util.uuid")

---@class Utils
---@field SimpleClass SimpleClass
---@field uuid uuid
return {SimpleClass = SimpleClass, uuid = uuid}