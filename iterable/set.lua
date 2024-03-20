local path = (...):gsub(".iterable.stack", "")
local class = require(path..".util.simpleClass")
local Iterable = require(path..".iterable.iterable")
---Set containing only unique elements
---@class Set: Iterable
local Set = class.extend(Iterable, "Set")

function Set:constructor(v)
    self._entries = {}
    self._hashMap = {}

    if Iterable.isIterable(v) then
        for index, value in v:iterate() do
            self:add(value)
        end
    else
        self:add(v)
    end

    self.super.constructor(self)
end

function Set.isSet(v)
    return v and type(v) == "table" and Set:isInstance(v)
end

function Set:filter(predicate)
    local newS = Set:new()

    for index, value in self:iterate() do
        if predicate(value, self, index) then
            newS:add(value)
        end
    end

    return newS
end

function Set:map(mapF)
    local newS = Set:new()

    for index, value in self:iterate() do
        newS:add(mapF(value, self, index))
    end

    return newS
end

function Set:contains(v)
    for index, value in self:iterate() do
        if value == v then
            return true
        end
    end

    return false
end

function Set:get(i)
    return self._entries[i]
end

function Set:add(v)
    if not self._hashMap[v] then
        self._hashMap[v] = true
        self._entries[#self._entries + 1] = v
    end
end

function Set:remove(v)
    if self._hashMap[v] then
        self._hashMap[v] = false
        for index, value in self:iterate() do
            if value == v then
                return table.remove(self._entries, index)
            end
        end
    end
end

function Set:toLuaArray()
    return table.pack(table.unpack(self._entries))
end

return Iterable