local love = love;
local lgraphics = love.graphics;

local fonts = fonts;

local utils = require"utils";
local _null_ = utils._null_;

local list;
list = Menu {
    MenuLabel {
        text = "Paused";
        font = fonts[36];
    },
    MenuLabel {
        text = "Quit";
        pos = 10;
        call = function()
            states:Pop("pause.main");
            states:Pop();
            states:Push("menu.main");
        end
    }
}

return Module {
    load = function(state_)
    end,
    draw = function()
        local lgraphics = lgraphics;

        lgraphics.setColor{64, 64, 64, 192};
        lgraphics.rectangle("fill", 0, 0, 800, 600);
        lgraphics.setFont(fonts[36]);
        lgraphics.setColor{255, 255, 255};
        list:Draw(100, 100, 30)
    end,
    keypressed = function(key, unicode)
        list:Keypressed(key, unicode);
    end
};