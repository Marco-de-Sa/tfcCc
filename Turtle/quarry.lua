local sx,sy,sz = gps.locate(2)
local ex,ey,ez = sx+10,sy-10,sz+10

function go_x()
    local x,_,_ = gps.locate(2)
    while ex ~= x do
        x,_,_ = gps.locate(2)
        turtle.forward()
    end
    turtle.up()
    turtle.down()
end

function go_up_y()
    local _,y,_ = gps.locate(2)
    while ey ~= y do
        x,y,_ = gps.locate(2)
        turtle.up()
    end
end

function go_down_y()
    local _,y,_ = gps.locate(2)
    while ey ~= y do
        x,y,_ = gps.locate(2)
        turtle.down()
    end
end

function go_z()
    local _,_,z = gps.locate(2)
    while ez ~= z do
        _,_,z = gps.locate(2)
        turtle.forward()
    end
    turtle.up()
    turtle.down()
end

function mine_to_x()
    turtle.dig()
    turtle.forward()
    local x,_,_ = gps.locate(2)
    print("mine_to_x")
    while not (ex <= x or sx >= x) do
        print("forward")
        print(x)
        turtle.dig()
        turtle.forward()
        x,_,_ = gps.locate(2)
    end
    mine_or_turn()
end

function new_layer()
    turtle.digDown()
    turtle.down()
    turtle.turnRight()
    turtle.turnRight()
end

function mine_or_turn()
    print("mine_or_turn")
	local x,y,z = gps.locate(2)
	local posy = sy - y
    local posz = sz - z
    print(posz)
    print( posz%2 == 0 and y == ey and x == sx )
    print( posz%2 == 1 and y == sy and x == sx )
    print(z == ez or z == sz)
    if (z == ez or z == sz) and (( posz%2 == 0 and y == ey and x == sx ) or( posz%2 == 1 and y == sy and x == sx )) then
        new_layer()
        mine_to_x()
        return
    end
    if (ex <= x and posy%2 == 0) or (sx >= x and posy%2 == 1) then
        print("turn1")
        turtle.turnRight()
        turtle.dig()
        turtle.forward()
        turtle.turnRight()
	end
	if (sx >= x and posy%2 == 0) or (ex <= x and posy%2 == 1) then
        print("turn2")
        turtle.turnLeft()
        turtle.dig()
        turtle.forward()
        turtle.turnLeft()
    end
    mine_to_x()
end
print(sx.." "..sz.." "..sy)
print(ex.." "..ez.." "..ey)
mine_to_x()
