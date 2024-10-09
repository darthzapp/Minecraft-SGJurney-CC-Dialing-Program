-- Initialisierung

transceiver = peripheral.find("transceiver")
interface = peripheral.find("crystal_interface")
redstone = peripheral.find("bundled_cable")
monitor = peripheral.find("monitor")

if transceiver then
    print("[INFO] Transceiver Connected")
    print("[INFO] IRIS Controlling Enabled")
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
-- update of a single value
function update(lineNumber, key, newValue)
    local tmpfilepath = "tmp.txt"
    local file = fs.open(filename, "r")
    local file_tmp = fs.open(tmpfilepath, "a")

    if not file or not file_tmp then
        print("Fehler beim Öffnen der Datei.")
        return
    end

    local currentLine = 1
    while true do
        local line = file.readLine()
        if line == nil then break end
        if currentLine == lineNumber then
            local updatedLine = ""
            local sep = ","
            local keyValuePairs = {}

            for k, v in string.gmatch(line, "([^,=]+)=([^,]+)") do
                if k == key then
                    keyValuePairs[k] = newValue 
                else
                    keyValuePairs[k] = v
                end
            end

            for k, v in pairs(keyValuePairs) do
                if updatedLine ~= "" then
                    updatedLine = updatedLine .. sep
                end
                updatedLine = updatedLine .. k .. "=" .. v
            end

            file_tmp.writeLine(updatedLine)
        else
            file_tmp.writeLine(line)
        end
        currentLine = currentLine + 1
    end

    file.close()
    file_tmp.close()

    fs.delete(filename)
    sleep(0.1)
    fs.move(tmpfilepath, filename)
end

function encode_line(inputstr)
    local sep = ","
    local t = {}

    for key, value in string.gmatch(inputstr, "([^,=]+)=([^,]+)") do
        t[key] = value
    end
    return t["label"], t["address"], t["on_iris_list"]
end

function findValue(parameter, key) -- findValueByAddress(address, key)
    local file = fs.open(filename, "r")
    if not file then
        print("Konnte die Datei nicht öffnen.")
        return nil
    end

    while true do
        local line = file.readLine()
        if line == nil then break end
        
        -- Entpacke die Zeile in Schlüssel-Wert-Paare
        local keyValuePairs = {}
        for k, v in string.gmatch(line, "([^,=]+)=([^,]+)") do
            keyValuePairs[k] = v
        end

        -- Überprüfe, ob die Adresse übereinstimmt
        if keyValuePairs["address"] == parameter then
            -- Rückgabe des Wertes für den angegebenen Schlüssel
            local value = keyValuePairs[key]
            file.close()
            return value  -- Rückgabe des Wertes für den angegebenen Schlüssel
        end
    end

    file.close()
    return nil  -- Wenn keine Übereinstimmung gefunden wurde
end

--------------------------------------------------------------------
-- ENDE SAVING
--------------------------------------------------------------------
--------------------------------------------------------------------
-- START MONITOR
--------------------------------------------------------------------
function draw_text(label, address, status, on_iris_list)
    if monitor then
        monitor.clear()
        monitor.setTextColor(colors.white)
        monitor.setTextScale(1)
        monitor.setCursorPos(1,1)
        if status == "Address Editing" then
            monitor.setTextColor(colors.yellow)
            monitor.write(status)
        elseif status == "Iris Editing" then
            monitor.setTextColor(colors.yellow)
            monitor.write(status)
        elseif status == "Dialing" then
            monitor.setTextColor(colors.yellow)
            monitor.write(status)
        elseif status == "Connected" then
            monitor.setTextColor(colors.green)
            monitor.write(status)
        end
        monitor.setTextColor(colors.white)
        monitor.setCursorPos(1,2)
        monitor.write(label)
        monitor.setCursorPos(1,3)
        monitor.write(address)
        if on_iris_list == "true" then
            monitor.setCursorPos(24,1)
            monitor.setTextColor(colors.green)
            monitor.write("SECURE")
        else
            monitor.setCursorPos(22,1)
            monitor.setTextColor(colors.red)
            monitor.write("UNSECURE")
        end
    end
end

--------------------------------------------------------------------
-- ENDE MONITOR
--------------------------------------------------------------------
--------------------------------------------------------------------
-- START EVENTHANDELING
--------------------------------------------------------------------
function get_address()
    raw_address = readLineFromFile(counter)
    if raw_address then
        label, address, on_iris_list = encode_line(raw_address)
    else
        label = "None"
        address = "-1-2-3-4-5-6-7-8-"
    end
    return label, address
end


counter = 1
redstone_counter = 0
while true do
    event, param1, param2, param3, param4 =  os.pullEvent()
    --sleep(0.3)
    if event == "transceiver_transmission_received" then
        --interface.closeIris()
        --interface.openIris()
        --if input_iris_mode then
        print("recived " .. param1 .." ".. param2)
        if param2 == code then
            interface.openIris()
        end


    elseif event == "stargate_incoming_wormhole" then
        if error_in_mod_is_fixed then
            print("incoming_wormhole")
            remote_address = param1
            print(remote_address)
            remote_address = addressToString(int(remote_address))
            print(remote_address)
            on_iris_list = findValueByAddress(remote_address, "on_iris_list")
        end
        if on_iris_list == "true" then
            interface.openIris()
        else
            interface.closeIris()
        end

    elseif event == "stargate_outgoing_wormhole" then
        interface.openIris()
        if transceiver then
            frequency = findValue(address, "remote_iris_frequency")
            code = findValue(address, "remote_iris_code")
            transceiver.setFrequency(frequency)
            transceiver.setCurrentCode(code)
            transceiver.sendTransmission()
        end

    elseif event == "stargate_reset" then
        interface.openIris()


-----------------------------------------------------------------------------
--REDSTONE EVENTHANDELING
-----------------------------------------------------------------------------
    elseif event == "redstone" then
        local input_reset = redstone.testBundledInput("back", colors.red)
        local input_next = redstone.testBundledInput("back", colors.black)
        local input_back = redstone.testBundledInput("back", colors.white)
        local input_dial = redstone.testBundledInput("back", colors.lime)
        local input_settings = redstone.testBundledInput("back", colors.blue)
        local input_iris = redstone.testBundledInput("back", colors.pink)
        local input_iris_mode = redstone.testBundledInput("back", colors.gray)

        label, address = get_address()
    ---------------------------------------
        if input_settings then
            status = "Address Editing"
        end
        if input_reset then
            if input_settings then
                print("deleted address at no: "..counter)
                print(label..", "..address.."deleted")
                deleteLineFromFile(counter)
            elseif input_iris_mode then
                print("Current: ".. frequenzy.. "Hz ".. code)
                print("Insert New Frequency:")
                frequency = int(io.read())
                print("Current: ".. frequenzy.. "Hz ".. code)
                print("Insert New Code:")
                code = io.read()
                update(counter, "remote_iris_frequency", frequency)
                update(counter, "remote_iris_code", code) 
            else
                counter = 1
                interface.disconnectStargate()
            end
            while redstone.testBundledInput("back", colors.red) do
                sleep(0.3)
            end
        end
    ---------------------------------------
        if input_next then
            if counter >= countLines() then
                counter = counter
            else
                counter = counter + 1
            end
            while redstone.testBundledInput("back", colors.black) do
                sleep(0.3)
            end
        end
    ---------------------------------------
        if input_back then
            if counter <= 1 then
                counter = counter
            else
                counter = counter - 1
            end
            while redstone.testBundledInput("back", colors.white) do
                sleep(0.3)
            end
        end
    ---------------------------------------
        if input_dial then
            if input_settings then
                print("Insert Address:")
                new_adress = io.read()
                print("Insert Label:")
                new_label = io.read()
                new_adress_str = "label="..new_label .. ",".. "address=" .. new_adress .. "," .. "on_iris_list=false,remote_iris_frequency=0000,remote_iris_code=0000",
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
    ---------------------------------------
        if input_iris then
            if input_settings then
                if on_iris_list == "false" then
                    on_iris_list = "true"
                else
                    on_iris_list = "false"
                end
                update(counter, "on_iris_list", on_iris_list)
            else
                if interface.getIrisProgressPercentage() == 0 then
                    interface.stopIris()
                    interface.closeIris()
                else 
                    interface.stopIris()
                    interface.openIris()
                end
            end
        end
       ---------------------------------------
    end
    draw_text(label, address, input_settings, on_iris_list)
end   
