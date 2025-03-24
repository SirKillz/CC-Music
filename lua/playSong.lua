local domain = "https://still-close-bobcat.ngrok-free.app"
local speaker = peripheral.find("speaker")
local dfpwm = require("cc.audio.dfpwm")
local decoder = dfpwm.make_decoder()
local monitor = peripheral.find("monitor")

local width, height = monitor.getSize()

-- Capture the command-line arguments into a table.
local args = { ... }

local title = args[1]
local video_id = args[2]
local file_path = args[3]

function getHorizonCenter(text, y)
    local width, height = monitor.getSize()
    local x = math.floor((width - string.len(text)) / 2)
    return x, y
end

function writeHeader(text, yPOS)
    monitor.setCursorPos(getHorizonCenter(text, yPOS)) 
    monitor.write(text)
end

function getSongContent()
    local response = http.get(domain .. "/v1/song?video_id=" .. video_id)
    return response
end

function createButton(text, color, y)
    monitor.setCursorPos(getHorizonCenter(text, y))
    local xMin = monitor.getCursorPos()
    monitor.setBackgroundColor(color)
    monitor.write(text)
    local xMax = monitor.getCursorPos()

    local position = {
        xMin = xMin,
        xMax = xMax,
        y = y
    }

    return position
end

-- This function will continuously read and play audio.
function audioLoop(songData)
    while true do
        local chunk = songData.read(16 * 1024)
        if not chunk then break end

        local decoded = decoder(chunk)
        while not speaker.playAudio(decoded) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end

-- This function waits for the stop button to be pressed.
function waitForStop(xMin, xMax, stopY)
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")
        if x >= xMin and x <= xMax and y == stopY then
            return "stop"
        end
    end
end

-- This function uses parallel.waitForAny to run both audioLoop and waitForStop concurrently.
function playSong(songData, xMin, xMax, stopY)
    parallel.waitForAny(
        function() audioLoop(songData) end,
        function() waitForStop(xMin, xMax, stopY) end
    )
    -- When the stop button is pressed (or audio finishes), return to displayHome:
    shell.run("displayHome")
end

function displayPlayingSong(title)
    writeHeader("Now playing:", 1)
    writeHeader(title, 3)
end

function main()
    if not title or not video_id or not file_path then
        print("Missing arguments! Expected: title, video_id, file_path")
        return
    end

    monitor.setBackgroundColor(colors.black)
    monitor.clear()
    displayPlayingSong(title)

    local stopButtonPosition = createButton("Stop", colors.red, height)
    local songData = getSongContent()
    playSong(songData, stopButtonPosition.xMin, stopButtonPosition.xMax, stopButtonPosition.y)
end

main()
