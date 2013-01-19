local love = love;
local states;
local msg = "";

return Module {
    load = function(states_, ticks, value)
        states = states_;
        msg = value;
    end,
    draw = function()
        local lgraphics = love.graphics;
        lgraphics.setColor{128, 128, 128, 224};
        lgraphics.rectangle("fill", 200, 200, 400, 200);
        lgraphics.setColor{255, 255, 255, 192};
        lgraphics.rectangle("line", 200, 200, 400, 200);
        lgraphics.setColor{255, 255, 255};
        lgraphics.print(msg, 250, 225);
    end,
    keypressed = function(key, unicode)
        states:Pop("objects.MessageBox");
    end
}
