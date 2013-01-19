local love = love;
local lgraphics = love.graphics;
local fonts = fonts;

local states;

local utils = require "utils";
local _null_ = utils._null_;
local capitalize = utils.capitalize;
local list = require "list";


local active = 1;

return Module{
    load = function(states_)
        states = states_;
    end,
    draw = function()
        lgraphics.setFont(fonts[48]);
        lgraphics.print("Lua Arcade", 200, 100);

        lgraphics.setFont(fonts[30]);
        for i, v in pairs(list.games) do
            lgraphics.print(capitalize(v[2]), 40, 140 + v[1]* 25);
        end
        lgraphics.print(">", 10, 140 + list.games[active][1] * 25);
    end,
    keypressed = function(key)
        if key == "up" and active > 1 then
            active = active - 1;
        elseif key == "down" and active < #list.games then
            active = active + 1;
        elseif key == "return" then
            list.load[active]();
        end
    end,
}

