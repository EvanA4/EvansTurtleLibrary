function Lumber ()
    local notEmpty, data = turtle.inspect()
    if (data.name ~= "minecraft:spruce_log") then
        print("This is not a spruce tree! Quitting...")
        return false
    end

    -- begin cutting wood from bottom right of tree
    turtle.dig()
    turtle.forward()
    while (data.name == "minecraft:spruce_log") do
        turtle.dig()
        turtle.turnLeft()
        turtle.dig()
        turtle.turnRight()
        turtle.digUp()
        turtle.up()

        notEmpty, data = turtle.inspect()
    end

    -- finish last layer of tree
    turtle.dig()
    turtle.turnLeft()
    turtle.dig()
    turtle.turnRight()

    -- cut down remaining pole
    turtle.forward()
    turtle.turnLeft()
    notEmpty, data = turtle.inspect()
    if (data.name == "minecraft:spruce_log") then turtle.dig() end
    while (turtle.detectDown() == false) do
        turtle.down()
        turtle.dig()
    end

    -- reset position
    turtle.turnRight()
    turtle.back()
    turtle.back()

    return true
end


-- minifunction: return key with smallest integer as its value
function Minimum (idxs)
    local min = 65
    local out = 0
    for key, value in pairs(idxs) do
        if (value < min) and (value ~= 0) then
            min = value
            out = key
        end
    end
    return out
end


function Replace ()
    -- detect if we even have enough
    local total = 0
    local idxs = {} -- create list of all indexes with saplings and their counts
    for i = 1, 16, 1 do
        local slot = turtle.getItemDetail(i)
        if type(slot) ~= "nil" then
            if slot.name == "minecraft:spruce_sapling" then
                total = total + slot.count
                idxs[i] = slot.count
            end
        end
    end
    if (total < 4) then return false end

    -- start with smallest stack
    local min = Minimum(idxs)
    turtle.select(min)

    -- go to back corner and plant sapling
    turtle.forward()
    turtle.forward()
    turtle.turnLeft()
    turtle.place()
    idxs[min] = idxs[min] - 1
    turtle.turnRight()
    turtle.back()

    -- plant other 3 saplings
    -- if we run out of saplings in stack, go to next stack
    if (turtle.place() == false) then
        min = Minimum(idxs)
        turtle.select(min)
        turtle.place()
    end

    turtle.turnLeft()
    if (turtle.place() == false) then
        min = Minimum(idxs)
        turtle.select(min)
        turtle.place()
    end

    turtle.turnRight()
    turtle.back() -- return to station
    if (turtle.place() == false) then
        min = Minimum(idxs)
        turtle.select(min)
        turtle.place()
    end

    return true
end


function ItemSort ()
    local items = {}
    -- read inventory to table (items and their slots w/ item count)
    for i = 1, 16, 1 do
        local slot = turtle.getItemDetail(i)
        if type(slot) ~= "nil" then
            if (type(items[slot.name]) == "nil") then
                items[slot.name] = {}
            end
            items[slot.name][i] = slot.count
        end
    end

    -- for each item
    for item, data in pairs(items) do
        for midx, mcount in pairs(data) do
            turtle.select(midx)

            -- for each slot of item
            local passedSelf = false
            for i, c in pairs(data) do
                -- go through every next slot and fill until main slot is empty OR the slot is full (use bool value to determine which case)
                if (passedSelf) then
                    if (turtle.transferTo(i, 64) == true) then break end
                end
                if (i == midx) then passedSelf = true end
            end
        end
    end
end


function GetCoal (maxCoal)
    -- suck up whole choal chest and sort
    while (turtle.suck(64)) do end
    ItemSort()

    -- drop everything beyond a stack
    -- find current total
    local total = 0
    for i = 1, 16, 1 do
        local slot = turtle.getItemDetail(i)
        if type(slot) ~= "nil" then
            if slot.name == "minecraft:charcoal" then
                total = total + slot.count
            end
        end
    end

    -- actual dropping
    while (total > 64) do
        for i = 1, 16, 1 do
            turtle.select(i)
            local slot = turtle.getItemDetail()
            if type(slot) ~= "nil" then
                if slot.name == "minecraft:charcoal" then
                    turtle.drop(math.min(64, total - maxCoal))
                    break
                end
            end
        end

        total = 0
        for i = 1, 16, 1 do
            local slot = turtle.getItemDetail(i)
            if type(slot) ~= "nil" then
                if slot.name == "minecraft:charcoal" then
                    total = total + slot.count
                end
            end
        end
    end
end


function Main ()
    while (true) do
        -- Wait for tree to grow
        -- assuming in front of tree:
        local notEmpty, data = turtle.inspect()
        while (data.name ~= "minecraft:spruce_log") do
            sleep(1)
            notEmpty, data = turtle.inspect()
        end

        -- Cut down tree and wait for leaves to decay
        if (Lumber() == false) then break end

        -- Open hopper below and take out everything
        for i = 1, 6, 1 do
            if (turtle.detectDown() == true) then turtle.digDown() end
            turtle.down()
        end
        while (true) do
            if turtle.suckDown(64) == false then break end
        end

        -- Burn the sticks as fuel
        for i = 1, 16, 1 do
            turtle.select(i)
            local slot = turtle.getItemDetail()
            if type(slot) ~= "nil" then
                if slot.name == "minecraft:stick" then
                    turtle.refuel(64)
                end
            end
        end

        -- Store logs and extra saplings in chest
        for i = 1, 6, 1 do turtle.up() end
        turtle.turnLeft()
        for i = 1, 16, 1 do
            turtle.select(i)
            local slot = turtle.getItemDetail()
            if type(slot) ~= "nil" then
                if slot.name == "minecraft:spruce_log" then
                    turtle.drop(64)
                end
            end
        end
        -- Sort saplings
        ItemSort()
        -- Find slot with most saplings
        local maxslot
        local max = 0
        for i = 1, 16, 1 do
            local slot = turtle.getItemDetail(i)
            if type(slot) ~= "nil" then
                if slot.name == "minecraft:spruce_sapling" then
                    if (slot.count > max) then
                        maxslot = i
                        max = slot.count
                    end
                end
            end
        end
        -- Toss all other slots with saplings into chest
        for i = 1, 16, 1 do
            if i ~= maxslot then
                turtle.select(i)
                local slot = turtle.getItemDetail()
                if type(slot) ~= "nil" then
                    if slot.name == "minecraft:spruce_sapling" then
                        turtle.drop(64)
                    end
                end
            end
        end

        -- Take any coal until 1 stack
        turtle.turnLeft()
        -- find the slot with coal in it
        GetCoal(64)
        turtle.turnRight()
        turtle.turnRight()

        -- Place saplings
        if (Replace() == false) then
            print("Ran out of saplings! Quitting...")
            break
        end

        -- Refuel if necessary
        if (turtle.getFuelLevel() < 1000) then
            for i = 1, 16, 1 do
                turtle.select(i)
                local slot = turtle.getItemDetail()
                if type(slot) ~= "nil" then
                    if slot.name == "minecraft:charcoal" then
                        local ctr = 0
                        while (turtle.getFuelLevel() < 1000) do
                            if (slot.count - ctr == 0) then
                                -- if ran out of coal during refueling, break
                                print("Critical fuel levels! Quitting...")
                                turtle.down()
                                return
                            end
                            turtle.refuel(1)
                            ctr = ctr + 1
                        end
                    end
                end
            end
        end
    end
end


Main()