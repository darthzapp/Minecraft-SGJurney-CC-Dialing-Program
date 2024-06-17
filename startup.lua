-- Monitor als Ziel wählen
monitor = peripheral.find("monitor") -- Ändern Sie "right" auf die Seite, an der Ihr Monitor angeschlossen ist

-- Hilfsfunktion zum Zeichnen eines Pixels
function setPixel(monitor, x, y, color)
    monitor.setCursorPos(x, y)
    monitor.setBackgroundColor(color)
    monitor.write(" ")
end

-- Bresenham-Kreisalgorithmus
function drawCircle(monitor, centerX, centerY, radius, color)
    local x = radius
    local y = 0
    local decisionOver2 = 1 - x  -- Entscheidungskriterium

    while y <= x do
        setPixel(monitor, centerX + x, centerY + y, color)
        setPixel(monitor, centerX + y, centerY + x, color)
        setPixel(monitor, centerX - x, centerY + y, color)
        setPixel(monitor, centerX - y, centerY + x, color)
        setPixel(monitor, centerX - x, centerY - y, color)
        setPixel(monitor, centerX - y, centerY - x, color)
        setPixel(monitor, centerX + x, centerY - y, color)
        setPixel(monitor, centerX + y, centerY - x, color)
        y = y + 1

        if decisionOver2 <= 0 then
            decisionOver2 = decisionOver2 + 2 * y + 1  -- Ändere Entscheidungskriterium
        else
            x = x - 1
            decisionOver2 = decisionOver2 + 2 * (y - x) + 1  -- Ändere Entscheidungskriterium
        end
    end
end

-- Hauptprogramm
monitor.clear()
monitor.setTextScale(0.5) -- Optional: Setzt die Textskalierung für mehr Details
local width, height = monitor.getSize()
local centerX = math.floor(width / 2)
local centerY = math.floor(height / 2)
local radius = 10
local color = colors.red

drawCircle(monitor, centerX, centerY, radius, color)
