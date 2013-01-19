local setmetatable = setmetatable;
local rawget, rawset = rawget, rawset;
local type = type;

-- My reasoning for this function is I saw it used in a similar project.
-- local thing = enum 'name_of_enum' {'list', 'of', things'};
-- print(thing.list == thing.of) --> false
-- print(enum.name_of_enum.thing) --> 'name_of_enum.thing'
-- local private = enum '.status' {'private', 'public'}; -- not listed under `enum` this time
local enum = setmetatable({}, {
    __call = function(self, name)
        local global = name:sub(1, 1) ~= ".";
        return function(list)
            local setmt, rawget = setmetatable, rawget;
            local type = type;
            local new = setmt({}, {
                __tostring = function(self) return name; end,
                __index = function(self, index)
                    return rawget(self, index) or error("No Value `" .. index .. "` in Enum `" .. name .. "`");
                end,
            });
            for i, v in pairs(list) do
                new[v] = setmt({}, {
                    __tostring = function(self) return name .. "." .. v; end,
                });
                print(v, new[v]);
            end
            if global then
                self[name] = new;
            end
            return new;
        end
    end,
    __index = function(self, index)
        return rawget(self, index) or error("No Enum `" .. index .. "` in Enum List", 2);
    end,
});

-- for making quick lookups like this:
-- local numbers = lookup{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
-- function is_number(char) return numbers[char]; end
local function lookup(list)
    local new = {};
    for i = 1, #list do
        new[list[i]] = true;
    end
    return new;
end

local function deepcopy(obj)
    local new = {};
    local constant = "table";
    for i,v in pairs(obj) do
        if type(v) == constant then -- if type == "table"
            new[i] = deepcopy(v);
        else
            new[i] = v;
        end
    end
    return new;
end

local function shallowcopy(obj)
    local new = {};
    for i,v in pairs(obj) do
        new[i] = v;
    end
    return new;
end

local function overwrite(greater, lesser)
    local new = deepcopy(lesser);
    for i,v in pairs(greater) do
        new[i] = v;
    end
    return new;
end

local function class(name)
    local extends;
    local inherited = false;
    local function gen(tab)
        assert(type(tab) == "table", "Error in Base Class `" .. name .. "`: Table expected");
        local mt = tab.__metatable or {};
        local new = {Init = tab.Init};
        local address = tostring(new):sub(8);
        local Init = tab.__Init;
        mt.__tostring = mt.__tostring or function(self)
            return "Class `" .. self.__Class.Name .. "` (" .. self.__Address .. ")";
        end
        tab.__metatable = nil
        tab.__Init = nil;
        new.mt = mt;
        new.Name = name;
        new.Master = tab;
        new.Init = Init;
        function new.Inherit(self, obj)
            if inherited then return; end   -- inheritance is static, only needs to be done once
            assert(extends, "Error in Class `" .. name .. "` (" .. obj.__Address .. "): No Superclass");
            inherited = true;
            local temp;
            for i = 1, #extends do
                for index, value in pairs(extends[i].Master) do
                    temp = tab[index];
                    temp = temp ~= nil and temp or value;
                    tab[index] = temp;
                    obj[index] = temp;
                end
                for index, value in pairs(extends[i].mt) do
                    temp = mt[index];
                    temp = temp ~= nil and temp or value;
                    mt[index] = temp;
                    obj[index] = temp;
                end
            end
        end
        function tab.IsA(self, param)
            return self.__Class.Name == param;
        end
        new = setmetatable(new, {
            __call = function(self, ...)
                local obj = {}
                local address = tostring(obj):sub(8);
                obj.__Address = address;
                obj.__Class = self;
                for i, v in pairs(tab) do
                    if type(v) == "table" then
                        obj[i] = deepcopy(v);
                    else
                        obj[i] = v;
                    end
                end
                setmetatable(obj, mt);
                if Init then Init(obj, ...); elseif extends then new.Inherit(self, obj); end
                return obj;
            end,
            __tostring = function(self)
                return "Base Class `" .. name .. "` (" .. address .. ")";
            end
        });
        if extends then
            if #extends > 1 then
                local extendsmod = {}; -- extends modified
                for i, v in pairs(extends) do
                    extendsmod[v.Name] = v;
                end
                new.SuperClass = extendsmod;
            else
                new.SuperClass = extends[1];
            end
        end
        return new;
    end
    return function(param)
        if type(param) == "table" then
            return gen(param);
        elseif param == "extends" then
            return function(...)
                extends = {...};
                assert(#extends > 0, "Classes expected");
                return gen;
            end
        end
    end
end

utils2 = {
    enum = enum;
    lookup = lookup;
    deepcopy = deepcopy;
    shallowcopy = shallowcopy;
    overwrite = overwrite;
    class = class;
};
return utils2;