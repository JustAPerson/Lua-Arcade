local love = love;
local lgraphics = love.graphics;
local fonts = fonts;

local utils = require"utils";
local _null_ = utils._null_;
local round = utils.round;

local last = 0;
local ticks = 0;
local speed = 0;
local SCORE = 0;
local snake = {
    dir = 0;
    last = 0;
    time = 0;
    segs = {
        {1, 1},
        {0, 0},
        {0, 0},
    },
};

local food = {
    list = {};
    add = function(self)
        self.list[#self.list + 1] = {math.random(1, 40), math.random(1, 30)};
    end,
    eat = function(self, n)
        table.remove(self.list, n);
        self:add();
        snake.segs[#snake.segs + 1] = {0, 0};
        SCORE = SCORE + math.ceil(10000/(ticks-snake.time));
        snake.time = ticks;
    end,
}

local directions = {
    [0] = {0, 0};
    [1] = {0, -1};
    [2] = {0, 1};
    [3] = {-1, 0};
    [4] = {1, 0};
};

local lost = 0
local debounce = true; -- prevent multiple key presses at once

local useBuffer, buffer = pcall(lgraphics.newFramebuffer);
local bufferRender = function()
    lgraphics.setColor{128, 128, 128};
    lgraphics.setLine(1, "rough");
    for x = 20, 780, 20 do
        lgraphics.line(x, 0, x, 600);
    end
    for y = 20, 580, 20 do
        lgraphics.line(0, y, 800, y);
    end
end
if useBuffer then buffer:renderTo(bufferRender); end

return  Module{
    load = function(start_tick, speed_)
        print("load snake");
        food:add();
        ticks = start_tick
        snake.time = start_tick;
        print(speed_)
        if speed_ == 1 then
            speed = 250;
        elseif speed_ == 2 then
            speed = 100;
        elseif speed_ == 3 then
            speed = 50;
        end
    end,
    draw = function()
        local lgraphics = lgraphics;
        local segs = snake.segs;
        local nsegs = #segs;
        local feed = food.list;

        if useBuffer then
        --    lgraphics.draw(buffer);
        else
         --   bufferRender();
        end

        lgraphics.setFont(fonts[18])
        lgraphics.setColor{255, 255, 255};
        lgraphics.print("Score: " .. SCORE, 0, 36);

        lgraphics.setColor(lost > 0 and {0, 64, 0} or {0, 128, 0});
        for i = 1, #feed do
            lgraphics.rectangle("fill", (feed[i][1]-1)*20, (feed[i][2]-1)*20, 20, 20);
        end

        if nsegs > 0 then
            lgraphics.setColor(lost > 0 and {128, 0, 0} or {128,128,128});
            lgraphics.rectangle("fill", (segs[1][1]-1)*20, (segs[1][2]-1)*20, 20, 20);
            lgraphics.setColor(lost > 0 and {255, 0, 0} or {255, 255, 255});
            for i = 2, nsegs do
                lgraphics.rectangle("fill", (segs[i][1]-1)*20, (segs[i][2]-1)*20, 20, 20);
            end
            lgraphics.setColor(lost > 0 and {128, 0, 0} or {128, 128, 128});
            for i = 1, nsegs do
                lgraphics.rectangle("line", (segs[i][1]-1)*20, (segs[i][2]-1)*20, 20, 20);
            end
        end
    end,
    update = function(dt, ticks_)
        ticks = ticks_;
        if ticks - speed > last then
            local a, b, old;
            local segs = snake.segs;
            local dir = directions[snake.dir];
            local feed = food.list;
            local x, y;
            last = ticks;

            if lost > 0 then
                if #segs == 0 then
                    lost = 2;
                else
                    table.remove(segs);
                end
            elseif lost == 0 then
                a = segs[1];
                old = a;
                x, y = a[1] + dir[1], a[2] + dir[2];
                x, y = x < 1 and 40 or x, y < 1 and 30 or y;
                x, y = x > 40 and 1 or x, y > 30 and 1 or y;

                segs[1] = {x, y};
                for i = 2, #segs do
                    if segs[i][1] == x and segs[i][2] == y and snake.dir > 0 then
                        -- lose
                        lost = 1
                        segs[1] = old;
                        SCORE = 0;
                        return;
                    end
                    b = segs[i];
                    segs[i] = a;
                    a = b;
                end
                snake.last = true;
                x, y = segs[1][1], segs[1][2];
                for i = 1, #feed do
                    if x == feed[i][1] and y == feed[i][2] then
                        -- Head touched food
                        food:eat(i);
                    end
                end
            end
        end
    end,
    keypressed = function(key)
        if not debounce then return; end
        debounce = false;

        local dir = snake.dir;
        local last = snake.last;

        if key == "up" and dir ~= 2 and last then
            snake.last = false
            snake.dir = 1
        elseif key == "down" and dir ~= 1 and last then
            snake.last = false
            snake.dir = 2
        elseif key == "left" and dir ~= 4 and last then
            snake.last = false
            snake.dir = 3
        elseif key == "right" and dir ~= 3 and last then
            snake.last = false;
            snake.dir = 4
        end

        if key == "return" and lost == 2 then
            lost = 0;
            snake.dir = 0;
            snake.segs = {
                {1, 1},
                {0, 0},
                {0, 0},
            }
        end

        debounce = true;
    end,
}