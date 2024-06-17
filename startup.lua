monitor = peripheral.find("monitor")

function download_images()
    shell.run(" ")
    print(" ")
end

function setPixel(x, y, color)
    term.setCursorPos(x, y)
    term.setBackgroundColor(color)
    term.write(" ")
end


function drawCircle(centerX, centerY, radius, color)
    local x = radius
    local y = 0
    local decisionOver2 = 1 - x  -- Entscheidungskriterium

    while y <= x do
        setPixel(centerX + x, centerY + y, color)
        setPixel(centerX + y, centerY + x, color)
        setPixel(centerX - x, centerY + y, color)
        setPixel(centerX - y, centerY + x, color)
        setPixel(centerX - x, centerY - y, color)
        setPixel(centerX - y, centerY - x, color)
        setPixel(centerX + x, centerY - y, color)
        setPixel(centerX + y, centerY - x, color)
        y = y + 1

        if decisionOver2 <= 0 then
            decisionOver2 = decisionOver2 + 2 * y + 1  -- Ändere Entscheidungskriterium
        else
            x = x - 1
            decisionOver2 = decisionOver2 + 2 * (y - x) + 1  -- Ändere Entscheidungskriterium
        end
    end
end

term.clear()
local centerX, centerY = term.getSize()
centerX = math.floor(centerX / 2)
centerY = math.floor(centerY / 2)
local radius = 10
local color = colors.red

drawCircle(centerX, centerY, radius, color)
