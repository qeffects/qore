-- Base class for all iterable data types

-- Doesn't contain any functionality, just defines common methods
local path = (...):gsub(".iterable.iterable", "")
local class = require(path..".util.simpleClass")
---@class Iterable: SimpleClass
local Iterable = class("Iterable")

function Iterable:constructor(v)
    self.isIterable = true
end

function Iterable.isIterable(v)
    return v and type(v) == "table" and v.isIterable
end

local function iterator(table, index)
    index = index + 1
    
    if table.iterationEnd == index then
        return
    end

    local value = table._entries[index]
    if value then
        return index, value
    end
end

function Iterable:iterate(start, length)
    local iterationStart = (start or 1) - 1
    self.iterationEnd = (length and iterationStart + length or #self._entries) + 1

    return iterator, self, iterationStart
end

function Iterable:forEach(func)
    for index, value in self:iterate() do
        func(value, index, self)
    end

    return self
end

function Iterable:filter()
    error("Iterable method :filter called, it's a placeholder method")
end

function Iterable:map()
    error("Iterable method :map called, it's a placeholder method")
end

function Iterable:toLuaArray()
    error("Iterable method :toLuaArray called, it's a placeholder method")
end

return Iterable