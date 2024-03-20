-- External interface
local PromiseInterface = {}

-- Internal class
local _PromiseClass = { class = "Promise" }
_PromiseClass.__index = _PromiseClass

-- Promise states:
local promiseStates = {
    waiting = "waiting",
    settled = "settled",
    errored = "errored",
}

local function internalNew(callback)
    local promiseState = {
        state = promiseStates.waiting,
        rejectValue = nil,
        returnValue = nil,
        nextcallbacks = {},
        catchcallbacks = {},
    }

    local promise = setmetatable(promiseState, { __index = _PromiseClass })

    return promise
end

local function isPromise(var)
    return var and type(var) == "table" and var.class == "Promise"
end

local function popNext(promise)
    local nextCb = promise.nextcallbacks[1]

    table.remove(promise.nextcallbacks, 1)
    
    return nextCb
end

---Resolves the promise
---@param value any
function _PromiseClass:resolve(value)
    if self.state == promiseStates.settled then
        return;
    end

    self.state = promiseStates.settled
    self.returnValue = value

    if isPromise(value) then
        value:next(self.resolve, self)
    else
        if #self.nextcallbacks > 0 then
            for index, nextcallback in ipairs(self.nextcallbacks) do
                local status, res

                if nextcallback.s then
                    status, res = pcall(nextcallback.callback, nextcallback.s, value)
                else 
                    status, res = pcall(nextcallback.callback, value)
                end
            
                nextcallback.nextPromise:resolve(res)
            end
        end
    end
end

function _PromiseClass:reject(value)

end

---Chains a callback for once the promise is settled
---Returns a new promise so you can continue chaining async functions
---@param callback function
---@return table
function _PromiseClass:next(callback, s)
    local res
    
    if self.state == promiseStates.waiting then
        res = internalNew()
        table.insert(self.nextcallbacks, {nextPromise = res, callback = callback, s = s})
    elseif self.state == promiseStates.settled then
        res = PromiseInterface.resolve(self.returnValue)
    end

    return res
end

---Handles any error that occured inside the promise/callbacks
---Returns the instance so you can continue chaining
---@param callback any
---@param s any
function _PromiseClass:catch(callback, s)
    table.insert(self.catchcallbacks, #self.catchcallbacks, {callback= callback, self = s})

    return self
end


--- Creates a new promise
---@param creatorFunction function
function PromiseInterface.new(creatorFunction)
    local promiseState = {
        state = promiseStates.waiting,
        rejectValue = nil,
        returnValue = nil,
        creatorFunction = creatorFunction,
        nextcallbacks = {},
        catchcallbacks = {},
    }

    local promise = setmetatable(promiseState, { __index = _PromiseClass })

    promise:creatorFunction()

    return promise
end

function PromiseInterface.resolve(val)
    local promiseState = {
        state = promiseStates.settled,
        rejectValue = nil,
        returnValue = val,
        nextcallbacks = {},
        catchcallbacks = {},
    }

    return setmetatable(promiseState, { __index = _PromiseClass })
end

function PromiseInterface.reject(err)

end

return PromiseInterface