local monitor = peripheral.find("monitor")
local currentYPOS = 0

function getHorizonCenter(text, y)
    local width, height = monitor.getSize()
    local x = math.floor((width - string.len(text)) / 2)
    return x, y
end

function writeHeader(text)
    monitor.setCursorPos(getHorizonCenter(text, currentYPOS+1))
    monitor.write(text)
end

function createButton(text, color, y)
    monitor.setCursorPos(getHorizonCenter(text, y))
    xMin = monitor.getCursorPos()
    monitor.setBackgroundColor(color)
    monitor.write(text)
    xMax = monitor.getCursorPos()

    position = {
        xMin = xMin,
        xMax = xMax,
        y = y
    }

    return position
end

function main()
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
    writeHeader("Select an option!")
    local viewLibraryPosition = createButton("View Library", colors.red, currentYPOS+7)
    local requestSongPosition = createButton("Request New Song", colors.green, currentYPOS+9)

    local waitingForSelection = true
    while waitingForSelection do
        local event, button, x, y = os.pullEvent("monitor_touch")
        if x >= viewLibraryPosition.xMin and x <= viewLibraryPosition.xMax and y == viewLibraryPosition.y then
            waitingForSelection = false
            shell.run("displayLibrary", "1")
        elseif x >= requestSongPosition.xMin and x <= requestSongPosition.xMax and y == requestSongPosition.y then
            waitingForSelection = false
            shell.run("requestSong")
        end
    end
end

main()