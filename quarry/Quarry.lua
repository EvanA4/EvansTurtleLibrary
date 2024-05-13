-- Error handling
function Main ()
    local doDig = true

    local l
    local w
    local d

    if (pcall(function ()
        l = tonumber(arg[1])
        w = tonumber(arg[2])
        d = tonumber(arg[3])

        if (type(d) == "nil") then
            doDig = false
        end
    end)) then
    else
       doDig = false
    end

    if (doDig == true) then
        Quarry(l, w, d)
    else
        print("usage: Quarry.lua [length] [width] [depth]")
    end
end


function ConfirmDig ()
    while (turtle.forward() == false) do
        turtle.dig()
    end
end


-- The actual digging
function Quarry (l, w, d)
    -- for each depth
    for i=1,d do
        -- for each column
        for j=1,w do
            -- for each block in column
            for k=2,l do
                ConfirmDig()
            end
            -- after a column
            if (w%2==1) or (w%2==0 and i%2==1) then
                if j<w and j%2==1 then
                    turtle.turnRight()
                    ConfirmDig()
                    turtle.turnRight()
                elseif j<w and j%2==0 then
                    turtle.turnLeft()
                    ConfirmDig()
                    turtle.turnLeft()
                else
                    if i<d then
                        turtle.digDown()
                        turtle.down()
                    end
                    turtle.turnRight()
                    turtle.turnRight()
                end
            else
                if j<w and j%2==0 then
                    turtle.turnRight()
                    ConfirmDig()
                    turtle.turnRight()
                elseif j<w and j%2==1 then
                    turtle.turnLeft()
                    ConfirmDig()
                    turtle.turnLeft()
                else
                    if i<d then
                        turtle.digDown()
                        turtle.down()
                    end
                    turtle.turnRight()
                    turtle.turnRight()
                end
            end
        end
    end
end


Main()