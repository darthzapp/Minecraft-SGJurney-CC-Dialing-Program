---orginal code by Povstalec
 
 
interface = peripheral.find("crystal_interface")
drive = peripheral.find("drive")
monitor = peripheral.find("monitor")

if monitor then
    print("[INFO] Monitor connected")
else
    print("[INFO] Monitor not detected")
end
if drive then
    print("[INFO] Drive connected")
else
    print("[ERROR] can not find Drive")
    os.exit()
end
if interface then
    print("[INFO] Crystal Interface connected")
else
    interface = peripheral.find("advanced_crystal_interface")
    if interface then
        print("[INFO] Advanced Crystal Interface connected")
    else
        interface = peripheral.find("basic_interface")  
        if interface then
            print("[ERROR] you need minimum of a Crystal Interface")
            os.exit()
        else
            print("[ERROR] can not find Drive")
            os.exit()
        end
    end  
end
--vars
maxenergy = 0
 
function dial_automatic(address) -- dialing for pegasus or universe stargate
    local addressLength = #address
    local start = interface.getChevronsEngaged() + 1
 
    for chevron = start,addressLength,1
    do        
        local symbol = address[chevron]
        interface.engageSymbol(symbol)
        local sleeptime = math.random(1, 2)
        os.sleep(sleeptime)  
    end
end
 
function dial_manual(address)
    local addressLength = #address
    local start = interface.getChevronsEngaged() + 1
 
    for chevron = start,addressLength,1
    do
        --This is a loop that will go through all the
        --symbols in an address
        
        local symbol = address[chevron]
        
        if chevron % 2 == 0 then
            interface.rotateClockwise(symbol)
        else
            interface.rotateAntiClockwise(symbol)
        end
        --Here we're basically making sure the gate ring
        --rotates clockwise when the number of chevrons
        --engaged is even and counter-clockwise when odd
        
        while(not interface.isCurrentSymbol(symbol))
        do
            sleep(0)
        end
        sleep(1)
        --We want to wait 1 second before we
        --engage the chevron
        interface.openChevron() --This opens the chevron
        sleep(1)
        interface.closeChevron() -- and this closes it
        sleep(1)        
    end 
end
 
-- MAIN DIALING CODE
function dial(address)
    sg_type = interface.getStargateType()
    if sg_type == "sgjourney:universe_stargate" or sg_type == "sgjourney:pegasus_stargate" or "sgjourney:tollan_stargate" then --or "sgjourney:classic_stargate"
        dial_automatic(address)
    else
        dial_manual(address)
    end
end
 
 
-- Disk saving system
 
function save_address(address,label)
    if drive then
        local file = fs.open("disk/data.txt", "w")
        file.write(address)
        file.close()
        drive.setDiskLabel(label)
    else
        print("Error: No disk detected. Please insert a diskette and try again.")
    end
end
drive = peripheral.find("drive")
function read_disk()
    if drive.hasData() then
        local file = fs.open("disk/data.txt", "r")
        local address = file.readAll()
        local label = drive.getDiskLabel()
        file.close()
        print(address)
         -- Hier wird die Funktion auf das disk-Objekt angewendet
        return address, label
    else
        print("Error: No disk detected. Please insert a diskette and try again.")
        return nil, nil
    end
end
 
function add_address()
    print("Please enter the address:")
    local address = io.read()
    print("Please enter the label:")
    local label = io.read()
 
    save_address(address, label)
end
 
function address_encode(address)
    local arr_address = {}
    for part in address:gmatch("[^-]+") do
        if part ~= nil then
            num = tonumber(part)
            table.insert(arr_address, tonumber(num))
        end
    end
    table.insert(arr_address, 0)
    return arr_address
end
 
--MONITOR

-- draw Circle
function setPixel(monitor, x, y, color)
    monitor.setCursorPos(x, y)
    monitor.setBackgroundColor(color)
    monitor.write("  ")
end

function drawCircle(radius, color)
    monitor.setTextScale(0.5)
    local width, height = monitor.getSize()
    local centerX = math.floor(width / 2)
    local centerY = math.floor(height / 2)

    local x = radius
    local y = 0
    local decisionOver2 = 1 - x

    monitor.setBackgroundColor(colors.black)
    while y <= x do
        setPixel(monitor, centerX + x, centerY + y / 1.5, color)
        setPixel(monitor, centerX + y, centerY + x / 1.5, color)
        setPixel(monitor, centerX - x, centerY + y / 1.5, color)
        setPixel(monitor, centerX - y, centerY + x / 1.5, color)
        setPixel(monitor, centerX - x, centerY - y / 1.5, color)
        setPixel(monitor, centerX - y, centerY - x / 1.5, color)
        setPixel(monitor, centerX + x, centerY - y / 1.5, color)
        setPixel(monitor, centerX + y, centerY - x / 1.5, color)
        y = y + 1
        if decisionOver2 <= 0 then
            decisionOver2 = decisionOver2 + 2 * y + 1
        else
            x = x - 1
            decisionOver2 = decisionOver2 + 2 * (y - x) + 1
        end
    end
    monitor.setBackgroundColor(colors.black)
end

function draw_stargate()
    color = colors.white
    drawCircle(18, color)
    drawCircle(17, color)
    drawCircle(16, color)
    drawCircle(15, color)
    if interface.isStargateConnected() then
        number = 14
        while number >= 1
        do
            drawCircle(number, colors.blue)
            number = number-1
        end
    else
        drawCircle(2, colors.red)
        drawCircle(1, colors.red)
    end
end

function draw_text(label)
    local width, height = monitor.getSize()
    local centerX = math.floor(width / 2)
    local centerY = math.floor(height / 2)
    if interface.isStargateConnected() then
        monitor.setCursorPos(centerX-3, centerY - 5)
        monitor.setBackgroundColor(colors.blue)
        monitor.setTextColor(colors.white)
        monitor.write("CONNECTED")
    else
        monitor.setCursorPos(centerX-1, centerY - 5)
        monitor.setBackgroundColor(colors.black)
        monitor.setTextColor(colors.white)
        monitor.write("IDLE")
    end
    openingtime = interface.getOpenTime()
    if openingtime ~= 0 then
        monitor.setCursorPos(centerX-1, centerY - 4)
        monitor.write(math.floor(openingtime/20))
        monitor.write("s")
    end
    if label then
        monitor.setCursorPos(centerX-3, centerY + 5)
        monitor.setTextColor(colors.white)
        monitor.write(label)
    else
        monitor.setCursorPos(centerX-4, centerY + 5)
        monitor.setTextColor(colors.yellow)
        monitor.write("INSERT DISC!")
    end
    energy = interface.getStargateEnergy()
    if energy > maxenergy then
        maxenergy = energy
    end
    if energy > 0 then
        monitor.setTextColor(colors.green)
        monitor.setCursorPos(centerX-4, centerY + 6)
        energylevel = energy / maxenergy
        if energylevel*100 < 50 then
            monitor.setTextColor(colors.yellow)
        end
        if energylevel*100 < 25 then
            monitor.setTextColor(colors.red)
        end
        monitor.write("PWR: ")
        monitor.write(math.floor(energylevel*100))
        monitor.write("%")
    else
        monitor.setCursorPos(centerX-3, centerY + 6)
        monitor.setTextColor(colors.red)
        monitor.write("NO ENERGY")
    end 
    monitor.setBackgroundColor(colors.black)
end

function draw_monitor(label)
    if monitor then
        monitor.clear()
        draw_stargate()
        draw_text(label)
    end
end
 
-- MAINLOOP
 
label = nil
while true do
    draw_monitor(label)
 
    local redstoneInput_bottom = redstone.getInput("bottom")
    local redstoneInput_top = redstone.getInput("top")
    if redstoneInput_top then
        if interface.isStargateConnected() == false then
            address, label = read_disk()
            draw_monitor(label)
            if address ~= nil then
                encoded_address = address_encode(address)
                dial(encoded_address)
            end
        else
           interface.disconnectStargate()
           os.sleep(2)
        end 
    elseif redstoneInput_bottom then
        add_address()
    end
    
    os.sleep(1) 
end
 
