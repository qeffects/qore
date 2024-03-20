local path = (...):gsub(".iterable.list", "")
local class = require(path..".util.simpleClass")
local Iterable = require(path..".iterable.iterable")
---In other words an array
---@class List: Iterable
local List = class.extend(Iterable, "List")

---Creates a new list
---@param ... any any array/list/single entry to be added to the list
function List:constructor(...)
    self._entries = {}
    self.iterationStart = nil
    self.iterationEnd = nil

    self:insert(1, ...)
    self.super.constructor(self)
end

---Checks if arg is list
---@param l any
function List.isList(l)
    if type(l) == "table" then
        if l.class and l.class == "List" then
            return true
        end
    end

    return false
end

---Returns the length of the list
---@return integer
function List:getLength()
    return #self._entries
end

---Returns a lua array representation of this List
---@return table
function List:toLuaArray()
    return table.pack(table.unpack(self._entries))
end

---Removes the last entry(ies) and returns it, if len>1 then it returns a new list of the removed values(in reversed order)
function List:pop()
    return table.remove(self._entries, #self._entries)
end

---Adds a new entry(ies) to the end
---@param e unknown
---@return List self returns itself for chaining
function List:push(e)
    if List.isList(e) then
        error("Cant push another list on to an existing list, use insert or join")
    else
        self._entries[#self._entries + 1] = e
    end
    return self
end

---Removes an entry from the beginning
---@return any v the first entry of the list
function List:shift()
    return table.remove(self._entries, 1)
end

---Adds a single entry to the beginning
---@param e any 
---@return List list
function List:unshift(e)
    return self:insert(1, e)
end

---Adds a list/table to the end
function List:join(...)
    return self:insert(nil, ...)
end

---Inserts a new entry(ies) at [index]
---@param index number?
---@param ... any
---@return List list the new list
function List:insert(index, ...)
    local entries = {...}
    index = index or self:getLength() + 1
    for _, value in ipairs(entries) do
        if Iterable.isIterable(value) then
            for _, e in value:iterate() do
                table.insert(self._entries, index, e)
                index = index + 1
            end
        elseif type(value) == "table" and value[1] and not value.class then
            for _, e in ipairs(value) do
                table.insert(self._entries, index, e)
                index = index + 1
            end
        else
            table.insert(self._entries, index, value)
        end
        index = index + 1
    end

    return self
end

---Returns a subset of the List as a new List
---@param start number
---@param stop number?
---@return List list the new list
function List:slice(start, stop)
    local ret = List:new()
    stop = stop or self:getLength()

    for _, value in self:iterate(start, stop - start + 1) do
        ret:push(value)
    end

    return ret
end

---Returns a subset of the current List as a new List and removes the range from the original
---@param start number the index to start at
---@param stop number? optional index to stop at
---@return List list the sliced list
function List:sliceRemove(start, stop)
    stop = stop or self:getLength()
    local ret = self:slice(start, stop)
    for i = stop, start, -1 do
        table.remove(self._entries, i)
    end

    return ret
end

---Returns a new reversed list
---@return List
function List:reverse()
    local l = List.new()

    for i, el in self:iterate() do
        l:unshift(el)
    end

    return l
end

---Reverses the same list in place
---@return List
function List:reverseInPlace()
    local l = {}

    for i, el in self:iterate() do
        table.insert(l,1, el)
    end

    self._entries = l

    return self
end

---Sorts the list in place based on the comparator function, returns the same list
---@param predicate fun(v1, v2): boolean
---@return List
function List:sortInPlace(predicate)
    table.sort(self._entries, predicate)

    return self
end

---Sorts the list based on the comparator function, returns a new sorted list 
---@param predicate fun(v1, v2): boolean
---@return List
function List:sort(predicate)
    local t = self:toLuaTable()
    table.sort(t, predicate)

    return List:new(t)
end

---Filters the list based by the filter function in place
---@param predicate fun(value, List, index): boolean
---@return List
function List:filterInPlace(predicate)
    local l = {}

    for index, value in self:iterate() do
        if predicate(value, self, index) then
            l[#l+1] = value
        end
    end

    self._entries = l

    return self
end

---Filters the list based by the filter function, returns a new one
---@param predicate fun(value, List, index): boolean
---@return List list The new filtered list
function List:filter(predicate)
    local newL = List:new()

    for index, value in self:iterate() do
        if predicate(value, self, index) then
            newL:push(value)
        end
    end

    return newL
end

---Maps the list in place
---@param mapper fun(val:any, list:List, index: number): any
---@return List
function List:mapInPlace(mapper)
    local l = {}
    for index, value in self:iterate() do
        l[#l+1] = mapper(value, self, index)
    end
    self._entries = l

    return self
end

---Maps the list on to a new list
---@param mapper fun(val:any, list:List, index: number): any
---@return List
function List:map(mapper)
    local newL = List:new()
    for index, value in self:iterate() do
        newL:push(mapper(value, self, index))
    end

    return newL
end

---Removes the indice at (index) and returns it
---@param index number|table
---@param stop number?
function List:remove(index, stop)
    if type(index) == "table" then
        for i = #index, 1, -1 do
            table.remove(self._entries, index[i])
        end
    else
        if stop then
            for i = stop, index, -1 do
                table.remove(self._entries, i)
            end
        end
        return table.remove(self._entries, index)
    end
end

function List:get(index)
    return self._entries[index]
end

function List:set(index, value)
    self._entries[index] = value
end

function List:clear()
    self:remove(1, self:getLength())
end

---Prints a (visual) string representation of this list
function List:print()
    local finStr = "List:["
    for index, value in self:iterate() do
        if type(value) == "number" then
            finStr = finStr..tostring(value)..", "
        end
        if type(value) == "string" then
            finStr = finStr..'"'..value..'"'..','
        end
    end
    print(finStr.."]")
end

return List