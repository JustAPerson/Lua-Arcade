local class = utils2.class;
local fonts = fonts;
local enum = utils2.enum;

Module = class 'Module' {
    __Init = function(self, list)
        self.DrawFunc = list.draw;
        self.DrawActive = list.draw ~= nil;
        self.UpdateFunc = list.update;
        self.UpdateActive = list.update ~= nil;
        self.KeypressedFunc = list.keypressed;
        self.KeypressedActive = list.keypressed ~= nil;
        self.LoadFunc = list.load;
        self.LoadActive = list.load ~= nil;
        self.UnloadFunc = list.unload;
        self.UnloadActive = list.unload ~= nil;
    end,
    Load = function(self, stack, ...)
        if self.DrawActive then
            stack.DrawStack:Push(self.DrawFunc);
        end
        if self.UpdateActive then
            stack.UpdateStack:Push(self.UpdateFunc);
        end
        if self.KeypressedActive then
            stack.KeypressedStack:Push(self.KeypressedFunc);
        end
        if self.LoadActive then
            self.LoadFunc(...);
        end
    end,
    Unload = function(self, stack)
        if self.DrawActive then
            stack.DrawStack:Pop();
        end
        if self.UpdateActive then
            stack.UpdateStack:Pop();
        end
        if self.KeypressedActive then
            stack.KeypressedStack:Pop();
        end
        if self.UnloadActive then
            self.UnloadFunc();
        end
    end,
};

Stack = class 'Stack' {
    Array = {};
    Pointer = 0;
    Push = function(self, value)
        local ptr = self.Pointer + 1;
        self.Pointer = ptr;
        self.Array[ptr] = value;
        return ptr;
    end,
    Pop = function(self, n)
        n = n or self.Pointer;
        assert(n > 0, "Stack Underflow");
        local temp = self.Array[n];
        table.remove(self.Array, n);
        self.Pointer = self.Pointer - 1;
        return temp;
    end,
    Read = function(self, n)
        n = n or self.Pointer;
        assert(n > 0, "Stack Null Pointer Exception");
        return self.Array[n];
    end,
    Write = function(self, value)
        assert(self.Pointer > 0, "Stack Null Pointer Exception");
        self.Array[self.Pointer] = value;
    end,
};

FunctionStack = class 'FunctionStack' 'extends' (Stack) {
    Call = function(self, ...)
        local array = self.Array;
        for i = 1, #array do
            array[i](...);
        end
    end,
};

Menu = class 'MenuList' {
    __Init = function(self, list)
        local slist = self.list;
        local v;
        for i = 1, #list do
            v = list[i];
            if not v.pos then v.pos = i; end
            slist[i] = v;
        end
    end,
    active = 1;
    list = {};
    call = {
        function(list)
            states:Pop("sanke.main");
            states:Push("snake.game", list.msgs[2].active);
        end,
        function() end,
    };
    Draw = function(self, x, y, size)
        local lgraphics = love.graphics;
        local font = fonts[size];
        local active = self.active;
        local width1, height = font:getWidth(">"), font:getHeight();
        lgraphics.setFont(font);
        active = self.list[active].pos or active;
        lgraphics.print(">", x, y + (active-1) * height);
        for i, v in next, self.list do
           if v.type == 1 then
               v:Draw(x + width1, y, font);
           elseif v.type == 2 then
               v:Draw(x + width1, y, font);
           end
        end
    end,
    Keypressed = function(self, key, unicode)
        local active = self.active;
        local item = self.list[active];
        if item:Keypressed(key, unicode) then return; end
        if key == "up" and active > 1 then
            self.active = active - 1;
        elseif key == "down" and active < #self.list then
            self.active = active + 1;
        end
    end
};

MenuLabel = class "MenuLabel" {
    __Init = function(self, list)
        -- self.pos set in MenuList.__Init();
        self.text = list.text;
        self.call = list.call and list.call or self.call;
        self.pos = list.pos;
    end,
    pos = nil;
    type = 1;
    call = function() end;
    Draw = function(self, x, y, font)
        local lgraphics = love.graphics;
        if self.font then lgraphics.setFont(self.font); end
        lgraphics.print(self.text, x, y + (self.pos - 1) * font:getHeight());
    end,
    Keypressed = function(self, key, unicode)
        if key == "return" then
            self:call();
            return true;
        end
    end,
};

MenuList = class "MenuList" "extends" (MenuLabel) {
    __Init = function(self, list)
        self.__Class:Inherit(self)
        self.__Class.SuperClass.Init(self, list);
        self.list = list.list and list.list or self.list;
        self.active = list.active and list.active or self.active;
    end,
    list = {};
    active = 1;
    type = 2;
    Draw = function(self, x, y, font)
        local lgraphics = love.graphics;
        local active = self.active;
        local text, opt = self.text, self.list[active];
        local width1, width2, width3, height;
        width1 = font:getWidth(">");
        width2 = font:getWidth(text);
        width3 = font:getWidth(opt);
        height = y + (self.pos - 1) * font:getHeight();
        if self.font then lgraphics.setFont(self.font); end
        lgraphics.print(text, x, height);
        lgraphics.print(opt, x + width1*2 + width2, height);
        if active > 1 then
            lgraphics.print("<", x + width1 + width2, height);
        end
        if active < #self.list then
            lgraphics.print(">", x + width1*2 + width2 + width3, height);
        end
    end,
    Keypressed = function(self, key, unicode)
        local active = self.active;
        if key == "left" and active > 1 then
            self.active = active - 1;
            return true;
        elseif key == "right" and active < #self.list then
            self.active = active + 1;
            return true;
        end
        return self.__Class.SuperClass.Master.Keypressed(self, key, unicode);
    end,
};


--[[
         local lgraphics = love.graphics;
        local msgs, item, selection;
        local sizex, sizey;
        local height , width;
        msgs = list.msgs;
        lgraphics.setFont(fonts[size]);
        height = fonts[size]:getHeight();
        width = fonts[size]:getWidth(">") + 5;
        for i = 1, #msgs do
            item = msgs[i];
            if item.type == enum.MenuObjects.Label then
                lgraphics.print(item.text, x + width,  y + (item.pos or i)*height);
            elseif item.type == 2 then
                selection = item.active;
                sizex = fonts[size]:getWidth(item.text);
                lgraphics.print(item.text, x + width, y + (item.pos or i)*height);
                if selection > 1 then
                    lgraphics.print("<", x + width + sizex, y + (item.pos or i)*height);
                end
                if selection < #item.options then
                    lgraphics.print(">", x + width*2 + sizex + fonts[size]:getWidth(item.options[selection]),
                        y + (item.pos or i)*height);
                end
                lgraphics.print(item.options[item.active], x + width*2 + fonts[size]:getWidth(item.text), y + (item.pos or i)*height);
            end
        end
        lgraphics.print(">", x, y + (msgs[list.active].pos or list.active)*height);
 ]]