---@module 'move'
local move = require("move")

local sx,sy,sz = gps.locate(2)
local ex,ey,ez = sx+10,sy-10,sz+10

---@enum jobs
local jobs = {mine = 0, empty = 1, rtp = 2, layer = 3}

---@class progress
---@field startcord table{x,y,z
---@field endcord table{x,y,z
---@field job jobs|nil
---@field jobcord nil|table{x,y,z
---@field job2 jobs|nil
---@field rtp nil|table{x,y,z
---@field save function()
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
        progress.job2 = jobs.empty
        progress.rtp = {x,y,z}
        progress.save()
        move.to(progress.startcord[1],progress.startcord[2],progress.startcord[3])
        ---move.to(sx,sy,sz)
        move.turnTo("west")
        for i = 1, 16 do
            turtle.select(i)
            turtle.drop()
        end
        progress.job2 = jobs.rtp
        progress.save()
        move.to(progress.rtp[1],progress.rtp[2],progress.rtp[3],{"x","z","y"})
        ---move.to(x,y,z)
        progress.job2 = nil
        progress.rtp = nil
        progress.save()
    end
end

function mine_two_layers()
    local x,y,z = gps.locate(2)
    ---@param a number @x 1 cord
    ---@param b number @x 2 cord
    ---@param zcond number @moveover variable
    ---@param condition number @z cord where to break loop
    local function m(a,b,zcond,condition)
        x,y,z = gps.locate(2)
        move.mineto(a, y, z,{"z","x"}, check_inv)
        while true do
            x,y,z = gps.locate(2)
            move.mineto(b, y, z+zcond,{"z","x"}, check_inv)
            x,y,z = gps.locate(2)
            if z == condition and x == b then
                print("Breaking")
                return
            end
            move.mineto(a, y, z+zcond,{"z","x"}, check_inv)
            x,y,z = gps.locate(2)
            if z == condition and x == a then
                print("Breaking")
                return
            end
        end
    end
    local firstrun = true
    while true do
        if firstrun then
            if progress.job2 == jobs.empty then
                move.to(progress.startcord[1],progress.startcord[2],progress.startcord[3])
                move.turnTo("west")
                for i = 1, 16 do
                    turtle.select(i)
                    turtle.drop()
                end
                move.to(progress.rtp[1],progress.rtp[2],progress.rtp[3],"x","z","y")
                progress.job2 = nil
                progress.rtp = nil
                progress.save()
            elseif progress.job2 == jobs.rtp then
                move.to(progress.rtp[1],progress.rtp[2],progress.rtp[3],"x","z","y")
                progress.job2 = nil
                progress.rtp = nil
                progress.save()
            end
            if progress.job == jobs.mine then
                if progress.jobcord[1] == sx and progress.jobcord[2] == y and progress.jobcord[3] == sz then
                    if z == (ez - 1) and (x == sx or x == ex) then
                        progress.job = jobs.layer
                        progress.jobcord = {ex,y-1,ez}
                        progress.save()
                        goto layer1
                    end
                    goto mine1
                elseif progress.jobcord[1] == ex and progress.jobcord[2] == y and progress.jobcord[3] == ez then
                    if z == (ez - 1) and (x == sx or x == ex) then
                        progress.job = jobs.layer
                        progress.jobcord = {sx,y-1,sz}
                        progress.save()
                        goto layer2
                    end
                    goto mine2
                else 
                    error("Turtle is not where it should be")
                end
            elseif progress.job == jobs.layer then
                if progress.jobcord[1] == ex and (progress.jobcord[2] == (y - 1) or progress.jobcord[2] == y) and progress.jobcord[3] == ez then
                    goto layer1
                elseif progress.jobcord[1] == sx and (progress.jobcord[2] == (y - 1) or progress.jobcord[2] == y) and progress.jobcord[3] == sz then
                    goto layer2
                end
            end
            firstrun = false
        end
        progress.job = jobs.mine
        progress.jobcord = {sx,y,sz}
        progress.save()
        ::mine1::
        m(ex,sx,1,ez-1)
        progress.job = jobs.layer
        progress.jobcord = {ex,y-1,ez}
        progress.save()
        ::layer1::
        x,y,z = gps.locate(2)
        if y == ey then
            move.mineto(ex,y,ez,{"x","z","y"}, check_inv)
            break
        end
        move.mineto(ex,y-1,ez,{"x","z","y"}, check_inv)
        ::mine2::
        m(sx,ex,-1,sz+1)
        progress.job = jobs.layer
        progress.jobcord = {sx,y-1,sz}
        progress.save()
        ::layer2::
        x,y,z = gps.locate(2)
        if y == ey then
            move.mineto(sx,y,sz,{"x","z","y"}, check_inv)
            break
        end
        move.mineto(sx,y-1,sz,{"x","z","y"}, check_inv)
    end
end

if not progress then
    progress = {
        startcord = {sx,sy,sz},
        endcord = {ex,ey,ez},
        job = nil,
        jobcord = nil,
        rtp = nil,
        save = function()
            local file = fs.open("progress","w")
            file.write(textutils.serialize(progress))
            file.flush()
            file.close()
        end
    }
    move.setOrientation("east")
else
    move.calibrateOrientation()
end

mine_two_layers()