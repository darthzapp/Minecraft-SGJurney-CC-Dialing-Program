-- Initialisierung 

interface = peripheral.find("crystal_interface")
redstone = peripheral.find("bundled_cable")
monitor = peripheral.find("monitor")

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
            print("[ERROR] can not find Interface")
            os.exit()
        end
    end  
end

if monitor then
    print("[INFO] Monitor connected")
else
    print("[INFO] Monitor not connected")
end

if redstone then
    print("[INFO] Bundled Cable not connected")
    print("[INFO] white = back, black = next, red = reset, blue = mode, lime = dial")
    print("[INFO] MODE: red = del, lime = add - mode switch has to be a lever")
else
    print("[WARN] Bundled Cable not connected")
    print("[ERROR] Bundled Cable not connected")
    os.exit()
end

--------------------------------------------------------------------
-- START Dialing
--------------------------------------------------------------------

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

-- MAIN DIALING CODE
function dial(address)
    sg_type = interface.getStargateType()
    if sg_type == "sgjourney:milky_way_stargate" or "milky_way_stargate" then
        print("dialing in manual mode")
        dial_manual(address) 
    else
        print("dialing in automatic mode")
        dial_automatic(address)
    end
end
--------------------------------------------------------------------
-- END DIALING
--------------------------------------------------------------------
local counter = 0
local filename = "data.txt"
--------------------------------------------------------------------
-- START SAVING
--------------------------------------------------------------------
function readLineFromFile(lineNumber)
    local file = fs.open(filename, "r")
    if not file then return nil end
    
    local currentLine = 1
    local content = nil
    while true do
        local line = file.readLine()
        if line == nil then break end
        if currentLine == lineNumber then
            content = line
            break
        end
        currentLine = currentLine + 1
    end
    file.close()
    return content
end

function createFileIfNotExists()
    if not fs.exists(filename) then
        local file = fs.open(filename, "w")
        file.close()
    end
end

-- Hilfsfunktion zum Einfügen einer Zeile in eine Datei
local function addLineIntoFile(newLine)
    local file = fs.open(filename, "a")
    if file then
        file.writeLine(newLine)
        file.close()
    end
end

function deleteLineFromFile(lineToDelete)
    local tmpfilepath = "tmp.txt"
    local file = fs.open(filename, "r")
    local file_tmp = fs.open(tmpfilepath, "a")
    local line = file.readLine()
    local linecounter = 1
    while line do
        if linecounter ~= counter then
            line = file.readLine()
            if line ~= nil  then
                file_tmp.writeLine(line)
            end
        end
        linecounter = linecounter + 1
    end
    file_tmp.close()
    file.close()
    fs.delete(filename)
    sleep(0.1)
    --rename
    fs.move(tmpfilepath, filename)
end

function countLines()
    local file = fs.open(filename, "r")
    if file then
        local lineCount = 0
        while true do
            local line = file.readLine()
            if line == nil then break end
            lineCount = lineCount + 1
        end
        file.close()
        return lineCount
    else
        print("Could not open File.")
        return 0
    end
end

function encode_line(inputstr) -- label, address = encode_line(inputstr)
    sep = ","
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t[1], t[2]
end

--------------------------------------------------------------------
-- ENDE SAVING
--------------------------------------------------------------------
--------------------------------------------------------------------
-- START MONITOR
--------------------------------------------------------------------
function draw_text(label, address, status)
    if monitor then
        monitor.clear()
        monitor.setTextScale(1)
        monitor.setCursorPos(1,1)
        monitor.write(status)
        monitor.setCursorPos(1,2)
        monitor.write(label)
        monitor.setCursorPos(1,3)
        monitor.write(address)
    end
end

--------------------------------------------------------------------
-- ENDE MONITOR
--------------------------------------------------------------------
--------------------------------------------------------------------
-- START MAINLOOP
--------------------------------------------------------------------
counter = 1
loop = 0
while true do
    loop = loop + 1
    local input_reset = redstone.testBundledInput("back", colors.red)
    local input_next = redstone.testBundledInput("back", colors.black)
    local input_back = redstone.testBundledInput("back", colors.white)
    local input_dial = redstone.testBundledInput("back", colors.lime)
    local input_settings = redstone.testBundledInput("back", colors.blue)

    raw_address = readLineFromFile(counter)
    if raw_address then
        label, address = encode_line(raw_address)
    else
        label = "None"
        address = "-1-2-3-4-5-6-7-8-"
    end
    if input_settings then
        status = "Editing"
    else
        status = ""
    end
    draw_text(label, address, status)
    
    if  input_reset then
        if input_settings then
            print("deleted address at no: "..counter)
            print(label..", "..address.."deleted")
            deleteLineFromFile(counter)
        else
            counter = 1
        end
        while redstone.testBundledInput("back", colors.red) do
            sleep(0.3)
        end
    end
    if  input_next then
        if counter >= countLines() then
            counter = counter
        else
            counter = counter + 1
        end
        while redstone.testBundledInput("back", colors.black) do
            sleep(0.3)
        end
    end
    if  input_back then
        if counter <= 1 then
            counter = counter
        else
            counter = counter - 1
        end
        while redstone.testBundledInput("back", colors.white) do
            sleep(0.3)
        end
    end
    if  input_dial then
        if input_settings then
            print("Insert Address:")
            new_adress = io.read()
            print("Insert Label:")
            new_label = io.read()
            new_adress_str = new_label .. ",".. new_adress
            print(new_adress_str)
            addLineIntoFile(new_adress_str)
        else
            if interface.isStargateConnected() then
                interface.disconnectStargate()
            else
                print("Destination: " .. label)
                print("at: " .. address)
                encoded_address = address_encode(address)
                dial(encoded_address)
            end
        end
        while redstone.testBundledInput("back", colors.lime) do
            sleep(0.3)
        end
    end


    sleep(0.3)
end
