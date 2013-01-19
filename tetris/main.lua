local love = love;
local lgraphics = love.graphics;

local utils = require "utils";

local text = "";
local last = "";
local color = {255, 255, 255};
local background_color = {45, 111, 210};
local state = {};
local active
local next_piece;
local ticks = 0;
local last = 0;
local direction = 1;
local pieces = require"tetris.shapes";


local copy;
function copy(t)
    local n = {};

    for i, v in pairs(t) do
        if type(v) == "table" then
            n[i] = copy(v)
        else
            n[i] = v;
        end
    end

    return n
end

local function CreatePiece(n)
    local new = copy(pieces[n]);
    next_piece.PosX = 350;
    next_piece.PosY = 0;
    state[#state + 1] = next_piece;
    active = next_piece;
    next_piece = new;
    next_piece.PosX = 590;
    next_piece.PosY = 80;
end

local function CheckPosition()
    local block;
    local new = false;

    if not active then
        return true;
    end

    if active.PosY  >= (600 - active.Directions[active.Direction].SizeY * 30) then
        CreatePiece(math.random(1, #pieces));
        new = true;
    else
        for s = 1, #state - 1 do
            block = state[s];
            local a = block.Directions[block.Direction].SizeX;
            local b = active.Directions[active.Direction].SizeX;
            if (active.PosX + a* 30 > block.PosX and active.PosX < block.PosX + b * 30) then
                b = active.Directions[active.Direction].SizeY;
                if active.PosY + b*30>= block.PosY then
                    if active.PosY == 0 then
                        state = {};
                        active = nil;
                        text = "You lose!";
                    else
                        CreatePiece(math.random(1, #pieces));
                        new = true;
                    end
                end
            end
        end
    end

    return new;
end

local function DrawPiece(block)
    local lgraphics = lgraphics;
    local dir = block.Directions[block.Direction];
    lgraphics.setColor(block.Color);

    local i = 0;
    for l = 1, dir.SizeY do
        for k = 1, dir.SizeX do
            i = i + 1;
            if dir[i] == 1 then
                lgraphics.rectangle("fill", block.PosX + (k-1) * 30, block.PosY + (l-1) * 30, 30, 30);
            end
        end
    end
end

local function FindOutline(piece, left)
    local outline = {};
    local dir = piece.Directions[piece.Direction];
    local px, py, sx, sy  = piece.PosX, piece.PosY, dir.SizeX, dir.SizeY
    for i = 1, sx do
        outline[i] = dir[(left and 1 or sx) + (i - 1)*sx];
    end
    return outline;
end

return Module {
    load = function()
        next_piece = pieces[math.random(1, #pieces)];
        CreatePiece(1);
    end,
    update = function(dt, ticks_, on)
        ticks = ticks_
        if ticks - 200 > last and active then
            last = ticks;
            if not CheckPosition() then
                active.PosY = active.PosY + 30;
            end
        end
    end,
    draw = function()
        love.graphics.setColor(background_color);
        love.graphics.rectangle("fill", 0, 0, 800, 600);	-- background
        love.graphics.setColor{0, 0, 0};
        love.graphics.rectangle("fill", 200, 0, 300, 600); -- main matrix
        love.graphics.rectangle("fill", 560, 50, 120, 180); -- next piece matrix
        DrawPiece(next_piece); -- next piece
        love.graphics.setColor{255, 255, 255};
        love.graphics.print(last, 0, 580)
        love.graphics.print(text, 300, 300);

        for s = 1, #state do
            DrawPiece(state[s]);
        end
    end,
    keypressed = function(key, unicode)
        CheckPosition();
        if not active then return; end

        -- ignore non-printable characters (see http://www.ascii-code.com/)
        local dir = active.Directions[active.Direction];
        local px, py, sx, sy  = active.PosX, active.PosY, dir.SizeX;
        local temp;
        local o1, o2
        if key == "left" and px > 200 then
            --[[o1 = FindOutline(active, true);
                            for i = 1, #state - 1 do
                                temp = state[s];
                                o2 = FindOutline(temp, false);
                            end
                            -- lol who knows]]
            active.PosX = px - 30;
        elseif key == "right" and (px + sx*30) < 500 then
            active.PosX = px + 30;
        elseif key == "up" then
            active.Direction = active.Direction + 1;
            if active.Direction % 5 == 0 then
                active.Direction = 1;
            end
            dir = active.Directions[active.Direction];
            temp = px + dir.SizeX*30 ;
            if temp > 500 then
                active.PosX = px - (temp - 500);
            end
        elseif key == "down" then
            active.PosY = py + 30;
        end
    end
}