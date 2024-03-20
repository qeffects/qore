local path = (...):gsub(".iterable", "")

---@class BoundedStack
local BoundedStack = require(path..".iterable.boundedStack")
---@class Iterable
local Iterable = require(path..".iterable.iterable")
---@class List
local List = require(path..".iterable.list")
---@class Set
local Set = require(".iterable.set")
---@class Stack
local Stack = require(path..".iterable.stack")

---@class Iterables
---@field BoundedStack BoundedStack
---@field Iterable Iterable
---@field List List
---@field Set Set
---@field Stack Stack
return {
    BoundedStack = BoundedStack,
    Iterable = Iterable,
    List = List,
    Set = Set,
    Stack = Stack,
}