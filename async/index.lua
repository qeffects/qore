local path = (...):gsub(".async", "")
---@type EventQueue
local EventQueue = require(path..".async.eventQueue")
---@type PromiseInterface
local Promise = require(path..".async.promise")
---@type Service
local Service = require(path..".async.service")

---@class Asyncs
---@field EventQueue EventQueue
---@field Promise PromiseInterface
---@field Service Service
return {EventQueue = EventQueue, Promise = Promise, Service = Service}