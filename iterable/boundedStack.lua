local path = (...):gsub(".iterable.stack", "")
local class = require(path..".util.simpleClass")
local Stack = require(path..".iterable.stack")
---Stack with a limit, if the limit is reached the first element gets pushed off the stack
---@class BoundedStack: Stack
local BoundedStack = class.extend(Stack, "BoundedStack")

function BoundedStack:constuctor(v, len)
    self.limit = len or 20

    self.super.constuctor(self, v)
end

function BoundedStack:push(v)
    if #self._entries + 1 > self.limit then
        table.remove(self._entries, 1)
    end

    self.super.push(self, v)
end

return BoundedStack