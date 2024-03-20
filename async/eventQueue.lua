local path = (...):gsub(".async.eventQueue", "")

local List = require(path..".iterable.list")
local Promise = require(path..".async.promise")

--FIFO stack
---@class Stack
---@field stack List
local Stack = { class = "Stack" }
Stack.__index = Stack

function Stack.new()
    local s = {
        stack = List:new(),
    }

    return setmetatable(s, {__index = Stack})
end

function Stack:send(e)
    self.stack:push(e)
end

function Stack:take()
    if self.stack:getLength() > 0 then
        return self.stack:shift()
    end
end

function Stack:peek()
    if self.stack:getLength() > 0 then
        return self.stack[1]
    end
end

---Vertical graph based event queue
---@class EventQueue
---@field debugName string
--@field children List
--@field subscribers List
--@field internalEventStack List
--@field hasConsumers boolean
--@field promises List
--@field middleware fun(val)
local EventQueue = { class = "EventQueue", isSubscribeable = true }
EventQueue.__index = EventQueue

local function noop(...) return ... end

---Creates a new event queue
---@param middleware any
---@return EventQueue
function EventQueue.new(middleware, defer, debugName)
    local ev = {
        middleware = middleware or noop,
        children = List:new(),
        subscribers = List:new(),
        promises = List:new(),
        internalEventStack = defer and List:new() or nil,
        defer = defer or false,
        debugName = debugName,
        firedHotness = 0
    }

    return setmetatable(ev, EventQueue)
end

---Sends an event to the queue
---@param val any
function EventQueue:send(val)
    -- Events can be cancelled by the middle ware by returning false
    if not (type(val) == "table") then
        error("Events must be tables")
    end

    if self.middleware then
        val = self.middleware(val)
    end

    if val then
        self.firedHotness = 1.5
        if self.defer then
            self.internalEventStack:push(val)
        else 
            self:processVal(val)
        end
    end
end

function EventQueue:flush()
    if self.defer then
        for i, event in self.internalEventStack:iterate() do
            self:processVal(event)
        end
        self.internalEventStack:clear()
    else
        error("Tried to flush a non-deferred event queue")
    end
end

function EventQueue:processVal(val)
    if self.children then
        for _, child in self.children:iterate() do
            child:send(val)
        end
    end
    if self.subscribers then
        local toBeRemoved = {}

        for i, sub in self.subscribers:iterate() do
            local ret = sub(val)
            
            if ret then
                toBeRemoved[#toBeRemoved+1] = i
            end
        end

        self.subscribers:remove(toBeRemoved)
    end
    if self.promises then
        for i, promise in self.promises:iterate() do
            promise:resolve(val)
        end

        self.promises:sliceRemove(1)
        self.hasPromises = false
    end
end

---Creates a promise that awaits for this event to fire once
---@return table
function EventQueue:await()
    local p = Promise.new(noop)

    self.promises:push(p)
    self.hasPromises = true

    return p
end

---Makes and returns a new stack for this event queue
function EventQueue:newStack()
    local s = Stack.new()

    self.children:push(s)

    return s
end

---Creates a default stack for this event queue
function EventQueue:createStack()
    self.eventStack = Stack.new()

    self.children:push(self.eventStack)

    return self.eventStack
end

---Gets the default stack
function EventQueue:getStack()
    return self.eventStack
end

---Subscribes to this event queue
---@param callback any
function EventQueue:subscribe(callback)
    self.subscribers:push(callback)
end

---Narrows down the parent event queue with a filter
---@param filterFunc any
---@return EventQueue
function EventQueue:filter(filterFunc, filterName)
    local ev = EventQueue.new(filterFunc, false, filterName)

    self.children:push(ev)

    return ev
end

---Returns an event queue that joins multiple queues (say you have mouse and keyboard event queues, it'll propagate events from both)
function EventQueue.join(...)
    local ev = EventQueue.new(nil, false, "Join")
    local param = table.pack(...)

    for index, value in ipairs(param) do
        if EventQueue.isEventQueue(value) then
            value.children:push(ev)
        else
            error("Can only join event queue instances")
        end
    end

    return ev
end

function EventQueue.isEventQueue(l)
    if type(l) == "table" then
        if l.class and l.class == "EventQueue" then
            return true
        end
    end

    return false
end

return EventQueue