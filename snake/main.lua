local fonts = fonts;
local states = states;
local ticks;

local list;
list = Menu {
    MenuLabel {
        text = "Play";
        call = function(self)
            states:Pop("snake.main");
            states:Push("snake.game", list.list[2].active);
        end
    },
    MenuList {
        text = "Speed:";
        active = 2;
        list = {
            "slow";
            "normal";
            "fast";
            "umad?";
        };
    },
};

return Module {
    load = function(ticks_, ...)
       ticks = ticks_;
    end,
    draw = function()
        local lgraphics = love.graphics;
        local msgs = list.msg;

       --[[ lgraphics.setFont(fonts[30]);
        for i = 1, #msgs do
           lgraphics.print(msgs[i][2], 40, 40 + msgs[i][1]* 25)
        end
        lgraphics.print(">", 10, 40 + msgs[active][1] * 25);]]
        list:Draw(40, 40, 30);
    end,
    keypressed = function(key, unicode)
        list:Keypressed(key, unicode);
    end,
}