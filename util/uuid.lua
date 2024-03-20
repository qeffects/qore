local _uuid = {
    inited = false
}

function _uuid.init()
    math.randomseed(love.timer.getTime() * 1000 + os.time(os.date('*t')) )
end

local function pad(str, len)
    local padLen = len - #str

    return string.rep("0", padLen)..str
end

---@class uuid
local function uuid()
    if not _uuid.inited then
        _uuid.init()
    end

    local low = pad(string.format("%x",math.random(0, 4294967295)), 8)
    local mid = pad(string.format("%x", math.random(0, 65535)), 4)
    local high = pad(string.format("%x", math.random(0, 65535)), 4)
    local uhigh = pad(string.format("%x", math.random(0, 65535)), 4)
    local node = pad(string.format("%x", math.random(0, 281474976710655)), 12)

    return  low .. "-" .. mid .. "-" .. high .. "-" .. uhigh .. "-" .. node
end

return uuid