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


function Pitstop (isRefuelling)
    -- minifunction: collects all logs and saplings from a station, as well as dropping off charcoal
    -- Assumes 1 stack of coal in inventory
    if (isRefuelling) then
        -- Move to coal chest
        turtle.turnLeft()
        if (turtle.detect() == true) then turtle.dig() end
        turtle.forward()

        -- Find slot with charcoal
        for i = 1, 16, 1 do
            turtle.select(i)
            local slot = turtle.getItemDetail()
            if type(slot) ~= "nil" then
                if slot.name == "minecraft:charcoal" then
                    turtle.dropDown(16)
                    break
                end
            end
        end

        -- Return to between both chests
        turtle.back()
        turtle.turnRight()
    else
        -- Pick up logs and saplings
        if (turtle.detect() == true) then turtle.dig() end
        turtle.forward()
        while (true) do
            if turtle.suckDown(64) == false then break end
        end
        turtle.back()
        ItemSort()
    end
end


function PassLeft (isRefuelling) -- TODO: incorperate isRefuelling to Pitstop function
    -- One pass on left side from default position
    -- Reach 1st turtle
    turtle.turnLeft()
    for i = 1, 8, 1 do
        if (turtle.detect() == true) then turtle.dig() end
        turtle.forward()
    end
    Pitstop(isRefuelling)

    -- Reach 2nd turtle
    for i = 1, 14, 1 do
        if (turtle.detect() == true) then turtle.dig() end
        turtle.forward()
    end
    Pitstop(isRefuelling)

    -- Return to station
    turtle.turnRight()
    turtle.turnRight()
    for i = 1, 22, 1 do
        if (turtle.detect() == true) then turtle.dig() end
        turtle.forward()
    end
    turtle.turnLeft()
end


function PassRight (isRefuelling)
    -- One pass on right side from default position
    -- Go to end
    turtle.turnRight()
    for i = 1, 25, 1 do
        if (turtle.detect() == true) then turtle.dig() end
        turtle.forward()
    end

    -- Reach 2nd turtle
    turtle.turnLeft()
    turtle.turnLeft()
    Pitstop(isRefuelling)

    -- Reach 1st turtle
    for i = 1, 14, 1 do
        if (turtle.detect() == true) then turtle.dig() end
        turtle.forward()
    end
    Pitstop(isRefuelling)

    -- Return to station
    for i = 1, 11, 1 do
        if (turtle.detect() == true) then turtle.dig() end
        turtle.forward()
    end
    turtle.turnRight()
end


-- minifunction: return key with largest integer as its value
function Maximum (idxs)
    -- Assumes there is at least non-empty slot
    local max = 0
    local out = 0
    for key, value in pairs(idxs) do
        if (value > max) then
            max = value
            out = key
        end
    end
    return out
end


function LoadLogs ()
    -- Move to left chest
    turtle.up()
    turtle.up()

    -- Calculate what half of total logs is
    local total = 0
    local idxs = {}
    for i = 1, 16, 1 do
        local slot = turtle.getItemDetail(i)
        if type(slot) ~= "nil" then
            if slot.name == "minecraft:spruce_log" then
                total = total + slot.count
                idxs[i] = slot.count
            end
        end
    end
    local split = math.floor(total / 2)

    -- While split is greater than 0, find slot with max number of logs and keep dropping
    while (true) do
        local maxslot = Maximum(idxs)
        turtle.select(maxslot)
        turtle.drop(math.min(64, split))

        -- calculate new split and slot
        if (split > idxs[maxslot]) then
            split = split - idxs[maxslot]
            idxs[maxslot] = 0
        else
            idxs[maxslot] = idxs[maxslot] - split
            break
        end
    end

    -- Move to right chest
    turtle.turnRight()
    turtle.forward()
    turtle.forward()
    turtle.turnLeft()

    -- Drop all other logs into right chest
    for slot, count in pairs(idxs) do
        if (count ~= 0) then 
            turtle.select(slot)
            turtle.drop(count)
        end
    end

    -- Return to station
    turtle.turnLeft()
    turtle.forward()
    turtle.forward()
    turtle.turnRight()
    turtle.down()
    turtle.down()
end


function GetCoal (maxCoal)
    -- find total amount of coal
    local total = 0
    for i = 1, 16, 1 do
        local slot = turtle.getItemDetail(i)
        if type(slot) ~= "nil" then
            if slot.name == "minecraft:charcoal" then
                total = total + slot.count
            end
        end
    end

    -- while total is below maxCoal, suck
    while (total < maxCoal) do
        turtle.suckDown(math.min(64, maxCoal - total))

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

    -- while total is above maxCoal, drop
    while (total > maxCoal) do
        for i = 1, 16, 1 do
            turtle.select(i)
            local slot = turtle.getItemDetail()
            if type(slot) ~= "nil" then
                if slot.name == "minecraft:charcoal" then
                    turtle.dropDown(math.min(64, total - maxCoal))
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

    ItemSort()
end


function Furnaces ()
    -- Get index of coal
    local idxs = {}
    for i = 1, 16, 1 do
        local slot = turtle.getItemDetail(i)
        if type(slot) ~= "nil" then
            if slot.name == "minecraft:charcoal" then
                idxs[i] = true
            end
        end
    end

    -- Refuel 1st furnace
    for idx, wasUsed in pairs(idxs) do
        if (wasUsed) then
            turtle.select(idx)
            turtle.drop(64)
        end
    end

    -- Refuel others
    for i = 1, 3, 1 do
        turtle.turnRight()
        turtle.forward()
        turtle.turnLeft()
        for idx, wasUsed in pairs(idxs) do
            if (wasUsed) then
                turtle.select(idx)
                turtle.drop(64)
            end
        end
    end

    -- Burn all saplings
    for i = 1, 16, 1 do
        turtle.select(i)
        local slot = turtle.getItemDetail()
        if type(slot) ~= "nil" then
            if (slot.name ~= "minecraft:charcoal") then turtle.dropDown(64) end
        end
    end

    -- Return to station
    turtle.turnLeft()
    turtle.forward()
    turtle.forward()
    turtle.forward()
    turtle.turnRight()
end


function CountItem (itemname)
    -- minifunction: count number of logs
    local total = 0
    for i = 1, 16, 1 do
        local slot = turtle.getItemDetail(i)
        if type(slot) ~= "nil" then
            if slot.name == itemname then
                total = total + slot.count
            end
        end
    end
    return total
end


function DropCoal(toDrop, isDown)
    -- minifunction: drops all but X full stacks of coal
    -- assumes there are at least X number of full stacks of coal in inventory

    local ctr = 0
    for i = 1, 16, 1 do
        turtle.select(i)
        local slot = turtle.getItemDetail()
        if type(slot) ~= "nil" then
            if slot.name == "minecraft:charcoal" then
                if (slot.count < 64) then
                    turtle.drop(64)
                else
                    ctr = ctr + 1
                    if (ctr > toDrop) then
                        if (isDown) then
                            turtle.dropDown(64)
                        else
                            turtle.drop(64)
                        end
                    end
                end
            end
        end
    end
end


function OutputCoal()
    -- Will keep a minimum of 8 stacks of charcoal in buffer chest
    -- All other coal is either one of 4 stacks in turtle or dropped into output chest
    -- Assumes minimum of 4 stacks of coal in inventory to begin with

    -- Turn to face glass pipe
    turtle.turnLeft()
    turtle.turnLeft()

    while true do
        -- Suck items until no coal left or inventory full
        while true do
            if (turtle.suckDown() == false) then break end
        end

        -- Determine if inventory is full
        local isFull = true
        for i = 1, 16, 1 do
            local slot = turtle.getItemDetail(i)
            if type(slot) == "nil" then isFull = false end
        end

        -- Drop all but 12 stacks of charcoal into output chest
        DropCoal(8, false)

        if (isFull == false) then break end
    end

    -- Drop remaining 8 stacks into buffer chest
    DropCoal(0, true)

    -- Return to position
    turtle.turnRight()
    turtle.turnRight()
end


function Main ()
    while (true) do
        -- While less than 4 stacks of logs, pass both sides
        local logcount = CountItem("minecraft:spruce_log")
        while (true) do
            sleep(30)
            PassLeft(false)
            logcount = CountItem("minecraft:spruce_log")
            if (logcount >= 512) then break end
            PassRight(false)
            logcount = CountItem("minecraft:spruce_log")
            if (logcount >= 512) then break end
        end

        -- Put logs into smelter and wait to collect coal
        LoadLogs()
        GetCoal(256)

        -- Refuel furnaces and wait to collect coal
        Furnaces()
        GetCoal(64)

        -- Refuel turtles
        PassLeft(true)
        PassRight(true)
        GetCoal(64)

        -- Refuel itself and wait to collect coal
        -- select slot with coal in it
        for i = 1, 16, 1 do
            turtle.select(i)
            local slot = turtle.getItemDetail()
            if type(slot) ~= "nil" then
                if slot.name == "minecraft:charcoal" then break end
            end
        end
        while (turtle.getFuelLevel() < 1000) do
            turtle.refuel(1)
        end

        -- Put excess coal into output chest
        OutputCoal()
    end
end


Main()
