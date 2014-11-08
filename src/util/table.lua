--encoding=utf-8
-----------------------------------------------------------------------------
--| Table相关的一些处理
-----------------------------------------------------------------------------
--[[
local table = require "table"
local string = require "string"
local print,setmetatable,type,pairs,tostring,next,getmetatable = print,setmetatable,type,pairs,tostring,next,getmetatable
]]--

--module("common.util.tableutil")

-- 深层拷贝一个table
cloneTable = function (object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function objinfo(obj)

    local meta = getmetatable(obj)
    if meta ~= nil then
        metainfo(meta)
    else
        print("no object infomation !!")
    end
end

function metainfo(meta)

    if meta ~= nil then
        local name = meta["__name"]
        if name ~= nil then
            metainfo(meta["__parent"])
            print("<"..name..">")
            for key,value in pairs(meta) do
                if not string.find(key, "__..") then
                    if type(value) == "function" then
                        print("\t[f] "..name..":"..key.."()")
                    elseif type(value) == "userdata" then
                        print("\t[v] "..name..":"..key)
                    end
                end
            end
        end
    end
end

function toString(obj)
    local lua = ""
    local t = type(obj)
    if t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "table" then
        lua = lua .. "{\n"
        for k, v in pairs(obj) do
            lua = lua .. "[" .. toString(k) .. "]=" .. toString(v) .. ",\n"
        end
        local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
            for k, v in pairs(metatable.__index) do
                lua = lua .. "[" .. toString(k) .. "]=" .. toString(v) .. ",\n"
            end
        end
        lua = lua .. "}"
    elseif t == "nil" then
        lua = lua .. "nil"
    else
        error("can not serialize a " .. t .. " type.")
    end
    return lua
end

function print_lua_table (lua_table, indent)
    indent = indent or 0
    if lua_table == nil then
        print(" nil ")
        return
    end
    for k, v in pairs(lua_table) do
        if k ~= "__index" then
            if type(k) == "string" then
                k = string.format("%q", k)
            end
            local szSuffix = ""
            if type(v) == "table" then
                szSuffix = "{"
            end
            local szPrefix = string.rep("    ", indent)
            formatting = szPrefix.."["..k.."]".." = "..szSuffix
            if type(v) == "table" then
                print(formatting)
                print_lua_table(v, indent + 1)
                print(szPrefix.."},")
            else
                local szValue = ""
                if type(v) == "string" then
                    szValue = string.format("%q", v)
                else
                    szValue = tostring(v)
                end
                print(formatting..szValue..",")
            end
        end
    end
end

function printTab(tab)
    for i,v in pairs(tab) do
        if type(v) == "table" then
            print("table",i,"{")
            printTab(v)
            print("}")
        else
            print(v)
        end
    end
end

getTableSize = function( t )
    local count = 0
    for k,v in pairs(t) do
        count = count + 1
    end
    return count
end

function util_search_table(fromtable,seq)
    local res=-1
    for index, value in pairs(fromtable) do
        if seq==value then
            res=index
            break
        end
    end
    return res
end

function concat_table(table1,table2)
    local res = {}
    if not table1 then table1 = {} end
    if not table2 then table2 = {} end
    for _, var in pairs(table1) do
        if var then
            table.insert(res,var)
        end
    end
    for _, var in pairs(table2) do
        if var then
            table.insert(res,var)
        end
    end
    return res
end

function copyTable(src_t,tar_t)
    assert(src_t,"src table is nil")
    assert(type(src_t) == "table","src table is not table")
    for key, var in pairs(src_t) do
    	tar_t[key] = var
    end
end