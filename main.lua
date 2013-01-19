local love = love;
local lgraphics = love.graphics;

fonts = setmetatable({},
    {__index = function(t, k)
        if not rawget(t, k) then
            t[k] = lgraphics.newFont("digital-sans-ef-medium.ttf", k);
        end
        return rawget(t, k);
    end,
    }
);

local utils = require "utils";
local utils2 = require "utils2";
require "classes";

local round = utils.round;

local rawget = rawget;

local ticks = 0;
local last_dt = 0;
local last_update = 0;
local on = true;

local UpdateStack = FunctionStack();
local KeypressedStack = FunctionStack();
local DrawStack = FunctionStack();
local ModuleStack = FunctionStack();
local GameStack = {
    UpdateStack= UpdateStack,
    KeypressedStack = KeypressedStack,
    DrawStack = DrawStack,
    ModuleStack = ModuleStack,
};

states = {};
local states = states;
states.namespace = {};
function states.Push(self, str, ...)
    local module;
    if self.namespace[str] then return; end
    module = require(str);
    self.namespace[str] = ModuleStack:Push(module);
    module:Load(GameStack, ticks, ...);
end
 function states.Pop(self, str)
    local ptr = self.namespace[str];
    local module;
    module = ModuleStack:Read(ptr);
    module:Unload(GameStack);
    ModuleStack:Pop(ptr);
    if str then self.namespace[str] = nil; end
end



local fonts = fonts;

function love.load()
    print(".main: Load()");
    math.randomseed(os.time());
    states:Push("menu.main");
end

function love.update(dt)
    last_dt = dt;
    ticks = ticks + round(dt * 1000);

    if ticks - 500 > last_update then   -- wait 500ms to update
        io.stdout:flush();
    end

    if on == true then
       UpdateStack:Call(dt, ticks);
    end
end

function love.keypressed(key, unicode)
    local extras = extras;

    if key == "escape" then
        if on then
            states:Push("pause.main");
        else
            states:Pop("pause.main");
        end
        on = not on;
        return;
    end

    KeypressedStack:Read()(key, unicode);
end

function love.draw()
    local extras = extras;
    local lgraphics = lgraphics;

    DrawStack:Call();

    lgraphics.setFont(fonts[12]);
    lgraphics.setColor{255, 255, 255};
    lgraphics.print("Ticks: " .. ticks, 0, 0);
    lgraphics.print("FPS: " .. round(1/last_dt, 1), 0, 18);
end