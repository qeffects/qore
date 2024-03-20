local path = (...):gsub(".qore", "")

---@type Asyncs
local async = require(path..".async")
---@type Iterables
local iterable = require(path..".iterable")
---@type Utils
local util = require(path..".util")

return {async = async, iterable = iterable, util = util}