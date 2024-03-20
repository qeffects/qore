local path = (...):gsub(".iterable.stack", "")
local class = require(path..".util.simpleClass")
local Iterable = require(path..".iterable.iterable")
---Simple First in Last Out stack
---@class Stack: Iterable
local Stack = class.extend(Iterable, "Stack")

function Stack:constructor(v)
    self._entries = {}
    self.iterationStart = nil
    self.iterationEnd = nil

    if Stack.isIterable(v) then
        self._entries = v:toLuaArray()
    elseif v then
        self:push(v)
    end

    self.super.constructor(self)
end

function Stack:contains(v)
    for _, value in self:iterate() do
        if value == v then
            return true
        end
    end

    return false
end

function Stack:map(func)
    local sn = Stack:new()
    for index, value in self:iterate() do
        sn:push(func(index, value, self))
    end

    return sn
end

function Stack:mapInPlace(func)
    local ne = {}
    for index, value in self:iterate() do
        table.insert(ne,func(index, value, self))
    end

    self._entries = ne

    return self
end

function Stack:toLuaArray()
    return table.pack(table.unpack(self._entries))
end

function Stack:reverse()
    local sn = Stack:new()

    for i = #self._entries, 1, -1 do
        sn:push(self._entries[i])
    end

    return sn
end

function Stack:reverseInPlace()
    local ne = {}
    
    for i = #self._entries, 1, -1 do
        table.insert(ne, self._entries[i])
    end

    self._entries = ne

    return self
end

function Stack:length()
    return #self._entries
end

function Stack:push(v)
    self._entries[#self._entries+1] = v

    return self
end

function Stack:pop()
    local v = table.remove(self._entries, #self._entries)

    return v
end

return Stack