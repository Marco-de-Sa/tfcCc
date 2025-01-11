---@module 'move'
local move = require("move.lua")

local sx,sy,sz = gps.locate(2)
local ex,ey,ez = sx+10,sy-10,sz+10

---@enum jobs
local jobs = {mine = 0, empty = 1, rtp = 2}

---@class progress
---@field startcord table{x,y,z
---@field endcord table{x,y,z
---@field job jobs
---@field jobcord table{x,y,z
local progress

function check_inv()
    local empty = 0
    for i = 1, 16 do
        if turtle.getItemCount(i) == 0 then
            empty = empty + 1
        end
    end
    if empty <= 1 then
        local x,y,z = gps.locate(2)
        move.to(sx,sy,sz)
        move.turnTo("west")
        for i = 1, 16 do
            turtle.select(i)
            turtle.drop()
        end
        move.to(x,y,z)
    end
end

function mine_two_layers()
    local x,y,z = gps.locate(2)
    ---@param a number @x 1 cord
    ---@param b function @x 2 cord
    ---@param zcond number @moveover variable
    ---@param condition function @condition to break loop
    local function m(a,b,zcond,condition)
        while true do
            move.mineto(a, y, z+zcond, check_inv)
            x,y,z = gps.locate(2)
            move.mineto(b, y, z+zcond, check_inv)
            x,y,z = gps.locate(2)
            if b() then
                break
            end
        end
    end
    while true do
        m(ex,sx,1,function () return z == ez end)
        move.mineto(x,y-1,z)
        m(sx,ex,-1,function () return z == sz end)
        move.mineto(x,y-1,z)
        x,y,z = gps.locate(2)
        if y == ey then
            break
        end
    end
end

move.setOrientation("east")
mine_two_layers()