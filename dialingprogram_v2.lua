-- Initialisierung

interface = peripheral.find("crystal_interface")
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
    if sg_type == "sgjourney:universe_stargate" or "sgjourney:pegasus_stargate" or "sgjourney:tollan_stargate" or "sgjourney:classic_stargate" then
        dial_automatic(address)
    else
        dial_manual(address)
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
local function readLineFromFile(lineNumber)
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

--------------------------------------------------------------------
-- ENDE SAVING
--------------------------------------------------------------------
--------------------------------------------------------------------
-- START MAINLOOP
--------------------------------------------------------------------
createFileIfNotExists(filename)
while true do
    -- Prüfen auf Redstone-Signale
    if redstone.getInput("right") then
        counter = counter + 1
        while redstone.getInput("right") do
            sleep(0.1)
        end
    end
    
    if redstone.getInput("left") then
        counter = counter - 1
        while redstone.getInput("left") do
            sleep(0.1)
        end
    end
    
    if redstone.getInput("front") then
        counter = 0
    end
    
    if redstone.getInput("top") then
        if interface.isStargateConnected() == false then
            local lineContent = readLineFromFile(counter)
            if lineContent then
                address_string = readLineFromFile(counter)
                address_encoded = address_encode(address_string)
                print("Dialing address no:  " .. counter .. ": " .. address_string)
                dial(address_encoded)
                
            else
                print("address" .. counter .. " not avaiable.")
            end
        else
            interface.disconnectStargate()
        end
    end
    
    if redstone.getInput("bottom") then
        print("editing mode enabled")
        while true do
            if redstone.getInput("left") then
                print("Please enter the address:")
                new_adress_str = io.read()
                addLineIntoFile(new_adress_str)
                no = countLines()
                print("added address at no: "..no)
                break
            elseif redstone.getInput("right") then
                print("deleted address at no: "..counter)
                deleteLineFromFile(counter)
                break
            end
            sleep(0.3)
        end
    end
    
    -- Kurze Wartezeit, um die CPU zu entlasten
    sleep(0.3)
end
