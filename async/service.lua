local path = (...):gsub(".async.service", "")
local List = require(path..".iterable.list")
local Service = {}
Service.__index = Service

local currentService
local allServices = List:new()

local filterFinished = function(v)
    return not (v.status == "finished")
end

function Service.flushAll()
    for index, ser in allServices:iterate() do
        ser:resume()
    end

    allServices:filterInPlace(filterFinished)
end

function Service.isInService()
    return not (currentService == nil)
end

function Service.new(serviceFunc, name)
    local co = coroutine.create(serviceFunc)
    local service = {
        coroutine = co,
        status = "yielded",
        awaitReturn = nil,
        name = name
    }

    service = setmetatable(service, Service)
    
    allServices:push(service)
    
    return service
end

function Service:resume(...)
    local succ, status
    if self.status == "yielded" then
        currentService = self
        succ, status = coroutine.resume(self.coroutine, ...)
        currentService = nil

        if coroutine.status(self.coroutine) == "dead" then
            self.status = "finished"
        end
    elseif self.status == "ready" then
        currentService = self
        succ, status = coroutine.resume(self.coroutine, self.awaitReturn) 
        currentService = nil

        if coroutine.status(self.coroutine) == "dead" then
            self.status = "finished"
        end
    end
    if succ == false then
        error(status)
    end
end

---@async
function Service.yield()
    currentService.status = "yielded"

    return coroutine.yield()
end

---@async
function Service.await(promisable, timeout, default)
    local cs = currentService
    cs.status = "awaiting"

    promisable:next(function (res)
        cs.status = "ready"
        cs.awaitReturn = res
    end)

    return coroutine.yield()
end

function Service.every(subscribeable, func)

end

function Service.once(subscribable, func)

end

return Service