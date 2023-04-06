local store_listings = {}

local current_page = 1

local monitor = peripheral.find("monitor")
local mt_name = peripheral.getName(monitor)
monitor.setTextScale(0.5)

local width,height = monitor.getSize()

local buffer = window.create(monitor,1,1,width,height)

local function make_exchange(y)
    y = y + (height-1) * (current_page-1)
    local l = store_listings[y]
    if y <= #store_listings then
        local invcheck = "execute unless entity @p[nbt={Inventory:[{id:\""..l[3].."\",Count:"..l[4].."b}]}] run "
        local checkstr = "execute if entity @p[nbt={Inventory:[{id:\""..l[3].."\",Count:"..l[4].."b}]}] run "
        local checkmoney = "execute if entity @p[scores={money="..l[2].."..}] run "
        local invcheckmoney = "execute unless entity @p[scores={money="..l[2].."..}] run "

        if l[1] == "buy" then

            commands.exec(checkmoney.."give @p "..l[3].." "..l[4])
            commands.exec(checkmoney.."tellraw @p [{\"text\":\"Success! (You had \",\"color\":\"green\"},{\"score\":{\"name\":\"*\",\"objective\":\"money\"},\"color\":\"green\"},{\"text\":\"$)\",\"color\":\"green\"}]")
            commands.exec(invcheckmoney.."tellraw @p [{\"text\":\"Not enough money! (You have \",\"color\":\"red\"},{\"score\":{\"name\":\"*\",\"objective\":\"money\"},\"color\":\"red\"},{\"text\":\"$)\",\"color\":\"red\"}]")
            commands.exec(checkmoney.."scoreboard players remove @p money "..l[2])
        else

            commands.exec(checkstr.."scoreboard players add @p money "..l[2])
            commands.exec(checkstr.."tellraw @p [{\"text\":\"Success! (You have \",\"color\":\"green\"},{\"score\":{\"name\":\"*\",\"objective\":\"money\"},\"color\":\"green\"},{\"text\":\"$)\",\"color\":\"green\"}]")
            commands.exec(invcheck.."tellraw @p [{\"text\":\"Not enough items!\",\"color\":\"red\"}]")
            commands.exec(checkstr.."clear @p "..l[3].." "..l[4])
            
        end

        commands.exec(checkstr.."clear @p "..l[1].." "..l[2])
    end
end
local function render()
    buffer.setVisible(false)
    buffer.clear()

    local current_line = 1

    for i=1+(height-1)*(current_page-1),(height-1)*current_page do
        local current_listing = store_listings[i]

        if i>#store_listings then break end
        
        buffer.setCursorPos(1,current_line)

        if current_listing[1] == "sell" then
            buffer.write(("%s %s -> %s$"):format(current_listing[4],current_listing[3],current_listing[2]))
        else
            buffer.write(("%s$ -> %s %s"):format(current_listing[2],current_listing[4],current_listing[3]))
        end

        current_line = current_line + 1
    end

    buffer.setCursorPos(1,height)
    buffer.write("<<<")
    buffer.setCursorPos(math.floor(width/2),height)
    buffer.write(current_page)
    buffer.setCursorPos(width-2,height)
    buffer.write(">>>")
    buffer.setVisible(true)
end

render()

while true do
    local _,side,x,y = os.pullEvent("monitor_touch")

    if (y < height) and mt_name == side then
        make_exchange(y)
    elseif mt_name == side then
        if x < width/2 then
            current_page = current_page-1
            if current_page < 1 then
                current_page = math.ceil(#store_listings/(height-1))
            end
        else
            current_page = current_page+1
            if current_page > math.ceil(#store_listings/(height-1)) then
                current_page = 1
            end
        end
    end

    render()
end
