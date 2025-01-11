local sx,sy,sz = gps.locate(2)
local ex,ey,ez = sx+10,sy-10,sz+10

-- mines to either the starting or end x coordinate then calls mine_or_turn
function mine_to_x()
    turtle.dig()
    turtle.forward()
    local x,_,_ = gps.locate(2)
    while not (ex <= x or sx >= x) do
        print(x)
        turtle.dig()
        turtle.forward()
        x,_,_ = gps.locate(2)
    end
    mine_or_turn()
end

--[[
saves the y coordinate relative to where it started then checks to see if it is at the correct coordinates to start a new layer 
if it is then it calls new_layer afterwards it calls mine_to_x and returns null. if it isn't at the correct position for a new layer
then it will make a right or left u turn depending on the x and y coordinate it is on relative to the starting coords
]]
function mine_or_turn()
	local x,y,z = gps.locate(2)
	local posy = sy - y
    if (( posy%2 == 0 and z == ez and x == ex ) or( posy%2 == 1 and z == sz and x == sx )) then
        new_layer()
        mine_to_x()
        return
    end
    if (ex <= x and posy%2 == 0) or (sx >= x and posy%2 == 1) then
        turtle.turnRight()
        turtle.dig()
        turtle.forward()
        turtle.turnRight()
	elseif (sx >= x and posy%2 == 0) or (ex <= x and posy%2 == 1) then
        turtle.turnLeft()
        turtle.dig()
        turtle.forward()
        turtle.turnLeft()
    end
    mine_to_x()
end

-- mines down goes down then turns around to position itself for a new layer
function new_layer()
    turtle.digDown()
    turtle.down()
    turtle.turnRight()
    turtle.turnRight()
end

-- moves forward until the turtle is at the chosen x coordinate
function go_x(cx)
    local x,_,_ = gps.locate(2)
    while cx ~= x do
        x,_,_ = gps.locate(2)
        turtle.forward()
    end
end

-- goes up in y coordinates till it reaches the starting y coordinate
function go_up_y()
    local _,y,_ = gps.locate(2)
    while sy ~= y do
        x,y,_ = gps.locate(2)
        turtle.up()
    end
end

-- goes down in y coordinates till it reaches the chosen y coordinate
function go_down_y(cy)
    local _,y,_ = gps.locate(2)
    while cy ~= y do
        x,y,_ = gps.locate(2)
        turtle.down()
    end
end

-- moves forward till the turtle reaches the chosen z coordinate
function go_z(cz)
    local _,_,z = gps.locate(2)
    while cz ~= z do
        _,_,z = gps.locate(2)
        turtle.forward()
    end
    turtle.up()
    turtle.down()
end

-- calls the mine_to_x function
mine_to_x()