example:

local class = require "util.simpleClass"

local Point = class("Point")

function Point:constructor(x, y)
    self.x = x
    self.y = y
end

function Point:distanceTo(x, y)
    return math.sqrt((x - self.x)^2 + (y - self.y)^2)
end

local Line = class.extend(Point, "Line")

function Line:constructor(x1, y1, x2, y2)
    self.super.constructor(self, x1, y1)

    self.endX = x2
    self.endY = y2
end

function Line:getLength()
    return self.super.distanceTo(self, self.endX, self.endY)
end

local l = Line:new(20, 20, 10, 10)

local p = Point:new(1, 1)

p:distanceTo(10, 10)
l:getLength()