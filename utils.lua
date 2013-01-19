local floor = math.floor;
local next = next;
local type = type;
local insert = table.insert;
local remove = table.remove;

local getHeight = love.graphics.getHeight;
local getWidth = love.graphics.getWidth;

local _copy;
function _copy(a)
    local type = type;
    local new = {};

    for i, v in next, new do
        if type(v) == "table" then
            new[i] = _copy(v);
        else
            new[i] = v;
        end
    end

    return new;
end

utils = {
    round = function(a, b)
        b = b or 1;
        return floor(a / b + 0.5) * b;
    end,
    copy = _copy; -- not declared here because of recursion
    push = function(a, b)
        return insert(a, b);
    end,
    pop = function(a, b)
        return remove(a, b);
    end,
    fracx = function(n)
        return getWidth()*n;
    end,
    fracy = function(n)
        return getHeight()*n;
    end,
    capitalize = function(str)
        return str:sub(1,1):upper() .. str:sub(2);
    end,

    _null_ = function() end,
};
return utils;