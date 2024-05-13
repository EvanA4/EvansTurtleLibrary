-- Error handling
function Main ()
    local doWall = true

    local w
    local h

    if (pcall(function ()
        w = tonumber(arg[1])
        h = tonumber(arg[2])

        if (type(h) == "nil") then
            doWall = false
        end
    end)) then
    else
        doWall = false
    end

    if (doWall == true) then
        turtle.select(1)
        Wall(w, h)
    else
        print("usage: Wall.lua [width] [height]")
    end
end


-- Return turtle to chest to grab blocks and go back to location
function GetMoreBlocks (x, y)
    for i=1,y do
        turtle.down()
    end

    turtle.turnLeft()

    for i=1,x do
        turtle.forward()
    end

    turtle.select(1)
    while (turtle.suck()) do end

    turtle.turnRight()
    turtle.turnRight()

    for i=1,x do
        turtle.forward()
    end

    turtle.turnLeft()

    for i=1,y do
        turtle.up()
    end
end


-- Accounts for running out of blocks
function ConfirmPlace (x, y)
    if (turtle.getItemCount() == 0) then
        if (turtle.getSelectedSlot() == 16) then
            -- We are out of blocks! Go to the chest to grab more.
            GetMoreBlocks(x, y)
        else
            turtle.select(turtle.getSelectedSlot() + 1)
            if (turtle.getItemCount() == 0) then
                -- We are out of blocks! Go to the chest to grab more.
                GetMoreBlocks(x, y)
            end
        end
    end

    turtle.place()
end


-- The higher-level movement
function Wall (w, h)
    -- for each column
    for i=1,w do
        -- place block
        if (i % 2 == 1) then
            ConfirmPlace(i - 1, 0)
        else
            ConfirmPlace(i - 1, h - 1)
        end

        -- if odd column, build up
        for j=2,h do
            if (i % 2 == 1) then
                turtle.up()
            else
                turtle.down()
            end

            -- place block
            if (i % 2 == 1) then
                ConfirmPlace(i - 1, j - 1)
            else
                ConfirmPlace(i - 1, h - j)
            end
        end

        -- move to next column
        turtle.turnRight()
        turtle.forward()
        turtle.turnLeft()
    end

    -- if turtle finishes up in the air, move it down
    if (w % 2 == 1) then
        for i=2,h do
            turtle.down()
        end
    end
end


Main ()