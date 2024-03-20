local SimpleClassInterface = {}

---@class SimpleClass
local SimpleClass = { __class = "SimpleClass" }
SimpleClass.__index = SimpleClass

---comment
---@generic V
---@param self V
---@param ... unknown
---@return V
function SimpleClass.new(self, ...)
    local instance = {}

    instance = setmetatable(instance, self.___mt)

    self.constructor(instance, ...)

    return instance
end

function SimpleClass:isInstance(obj)
    return obj and type(obj) =="table" and obj.___class and self.___class == obj.___class
end

function SimpleClass:getClassName()
    return self.___class
end

function SimpleClassInterface.new(_, name)
    if _ and not name then
        name = _
    end
    local class = {
        ___class = name,
        ___parent = false,
        ___mt = {}
    }
    class.___mt.__index = class

    return setmetatable(class, {__index = SimpleClass})
end

function SimpleClassInterface.extend(parent, name)
    local class = {
        ___class = name,
        ___parent = parent,
        ___mt = {},
        super = parent
    }

    class.___mt.__index = class

    return setmetatable(class, {__index = parent})
end

return setmetatable(SimpleClassInterface, {__call = SimpleClassInterface.new})