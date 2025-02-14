---@class move
---@field directions directions
---@field currentDirection number|nil
---@field turnRight function
---@field turnLeft function
---@field turnTo function
---@field calibrateOrientation function
---@field setOrientation function
---@field to function
---@field mineto function
local move = {currentDirection = nil}

---Directions enum
---@enum directions
---@type directions
move.directions = {
    north = 0,
    east = 1,
    south = 2,
    west = 3,
    [0] = "north",
    [1] = "east",
    [2]="south",
    [3]="west",
    ["0"]=0,
    ["1"]=1,
    ["2"]=2,
    ["3"]=3
}

---turns the turtle right
---@return nil
function move.turnRight()
    turtle.turnRight()
    move.currentDirection = (move.currentDirection + 1) % 4
end

---turns the turtle left
---@return nil
function move.turnLeft()
    turtle.turnLeft()
    move.currentDirection = (move.currentDirection - 1) % 4
end

---Turns the turtle to the target directions
---@return nil
---@param targetDirection directions
function move.turnTo(targetDirection)
    local targetDirValue = move.directions[targetDirection]
    print("Turning to " .. targetDirection)
    if ((move.currentDirection -1)%4) == targetDirValue then
        move.turnLeft()
        return
    end
    while move.currentDirection ~= targetDirValue do
        move.turnRight()
    end
end
---calibrate the orientation of the turtle
---@return boolean
function move.calibrateOrientation()
    print("Calibrating orientation...")
    local x, y, z = gps.locate(2)
    if not x then
        error("Unable to get GPS location. Ensure a GPS system is set up.")
    end

    -- Helper function to attempt calibration in the current layer
    local function attemptCalibration()
        local x1, _, z1 = gps.locate(2)
        if not x1 then
            error("Unable to get GPS location. Ensure a GPS system is set up.")
        end

        -- Try moving in each direction to determine orientation
        for i = 1, 4 do
            if turtle.forward() then
                local x2, _, z2 = gps.locate(2)
                if not x2 then
                    error("Unable to get GPS location. Ensure a GPS system is set up.")
                end

                -- Determine direction based on movement
                if x2 > x1 then
                    move.currentDirection = move.directions["east"]
                elseif x2 < x1 then
                    move.currentDirection = move.directions["west"]
                elseif z2 > z1 then
                    move.currentDirection = move.directions["south"]
                elseif z2 < z1 then
                    move.currentDirection = move.directions["north"]
                end

                -- Move back to the original position
                turtle.back()
                return true -- Calibration successful
            else
                -- Turn right to try the next direction
                turtle.turnRight()
            end
        end
        return false -- Calibration failed in this layer
    end

    -- Attempt calibration and move up if necessary
    while true do
        if attemptCalibration() then
            print("Calibration complete! Facing " .. move.directions[move.currentDirection])
            move.to(x, y, z) -- Move back to original position
            return
        else
            print("Unable to calibrate in this layer, moving up...")
            if not turtle.up() then
                error("Calibration failed! Unable to move up. Ensure the turtle has space.")
            end
        end
    end
end

---Alternative Calibration if orientation is known
---@param targetDirection string|number
---@return nil
function move.setOrientation(targetDirection)
    move.currentDirection = move.directions[targetDirection]
    print("Calibration complete! Facing " .. move.directions[move.currentDirection])
end

---Moves the turtle to the target coordinates
---first moves in the Y direction, then X, then Z
---@param targetX number
---@param targetY number
---@param targetZ number
---@param movePattern table | nil
---@return nil
function move.to(targetX, targetY, targetZ, movePattern)
    if not targetX or not targetY or not targetZ then
        error("Target coordinates are invalid (nil value)! Cannot move to target.")
    end

    print("Moving to target: X=" .. targetX .. ", Y=" .. targetY .. ", Z=" .. targetZ)

    local currentX, currentY, currentZ = gps.locate(2)
    if not currentX or not currentY or not currentZ then
        error("Unable to get current GPS position. Ensure the GPS system is set up.")
    end

    if not movePattern then
        movePattern = {"y","x","z"}
    end

    -- Calculate movement direction to target
    local deltaX = targetX - currentX
    local deltaY = targetY - currentY
    local deltaZ = targetZ - currentZ

    -- Move in Y direction (up/down)
    local function moveDY()
        if deltaY > 0 then
            for i = 1, math.abs(deltaY) do
                turtle.up()
            end
        elseif deltaY < 0 then
            deltaY = deltaY * -1
            for i = 1, math.abs(deltaY) do
                turtle.down()
            end
        end
    end

    -- Move in X direction
    local function moveDX()
        if deltaX > 0 then
            for i = 1, math.abs(deltaX) do
                move.turnTo("east")
                turtle.forward()
            end
        elseif deltaX < 0 then
            deltaX = deltaX * -1
            for i = 1, math.abs(deltaX) do
                move.turnTo("west")
                turtle.forward()
            end
        end
    end

    -- Move in Z direction
    local function moveDZ()
        if deltaZ > 0 then
            for i = 1, math.abs(deltaZ) do
                move.turnTo("south")
                turtle.forward()
            end
        elseif deltaZ < 0 then
            deltaZ = deltaZ * -1
            for i = 1, math.abs(deltaZ) do
                move.turnTo("north")
                turtle.forward()
            end
        end
    end

    for _,move in ipairs(movePattern) do
        local var = {x=moveDX,z=moveDZ,y=moveDY,X=moveDX,Z=moveDZ,Y=moveDY}
        var[move]()
    end

    print("Reached target position: X=" .. targetX .. ", Y=" .. targetY .. ", Z=" .. targetZ)
end

---Move and mine to target coordinates.
---first moves in the X direction, then Z, then Y
---@param targetX number
---@param targetY number
---@param targetZ number
---@param movePattern table | nil
---@param checkinv nil | function
---@return nil
function move.mineto(targetX, targetY, targetZ, movePattern, checkinv)
    if not targetX or not targetY or not targetZ then
        error("Target coordinates are invalid (nil value)! Cannot move to target.")
    end

    print("Moving to target: X=" .. targetX .. ", Y=" .. targetY .. ", Z=" .. targetZ)

    local currentX, currentY, currentZ = gps.locate(2)
    if not currentX or not currentY or not currentZ then
        error("Unable to get current GPS position. Ensure the GPS system is set up.")
    end

    if not checkinv then
        checkinv = function () end
    end

    if not movePattern then
        movePattern = {"x","z","y"}
    end

    -- Calculate movement direction to target
    local deltaX = targetX - currentX
    local deltaY = targetY - currentY
    local deltaZ = targetZ - currentZ
    local function moveDX()
        -- Move in X direction
        if deltaX > 0 then
            for i = 1, math.abs(deltaX) do
                move.turnTo("east")
                if deltaX >= i then
                    if turtle.dig() then
                        checkinv()
                    end
                end
                turtle.forward()
            end
        elseif deltaX < 0 then
            deltaX = deltaX * -1
            for i = 1, math.abs(deltaX) do
                move.turnTo("west")
                if deltaX >= i then
                    if turtle.dig() then
                        checkinv()
                    end
                end
                turtle.forward()
            end
        end
    end

    local function moveDZ()
        -- Move in Z direction
        if deltaZ > 0 then
            for i = 1, math.abs(deltaZ) do
                move.turnTo("south")
                if deltaZ >= i then
                    if turtle.dig() then
                        checkinv()
                    end
                end
                turtle.forward()
            end
        elseif deltaZ < 0 then
            deltaZ = deltaZ * -1
            for i = 1, math.abs(deltaZ) do
                move.turnTo("north")
                if deltaZ >= i then
                    if turtle.dig() then
                        checkinv()
                    end
                end
                turtle.forward()
            end
        end
    end

    local function moveDY()
        -- Move in Y direction (up/down)
        if deltaY > 0 then
            for i = 1, math.abs(deltaY) do
                if deltaY >= i then
                    if turtle.digUp() then
                        checkinv()
                    end
                end
                turtle.up()
            end
        elseif deltaY < 0 then
            deltaY = deltaY * -1
            for i = 1, math.abs(deltaY) do
                if deltaY >= i then
                    if turtle.digDown() then
                        checkinv()
                    end
                end
                turtle.down()
            end
        end
    end
    for _,move in ipairs(movePattern) do
        local var = {x=moveDX,z=moveDZ,y=moveDY,X=moveDX,Z=moveDZ,Y=moveDY}
        var[move]()
    end
    print("Reached target position: X=" .. targetX .. ", Y=" .. targetY .. ", Z=" .. targetZ)
end
---@return move
return move