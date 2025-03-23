local monitor = peripheral.find("monitor")
local currentYPOS = 1
local domain = "still-close-bobcat.ngrok-free.app"
local page = 1

function getHorizonCenter(text, y)
    local width, height = monitor.getSize()
    local x = math.floor((width - string.len(text)) / 2)
    return x, y
end

function writeHeader(text)
    monitor.setCursorPos(getHorizonCenter(text, 1))
    monitor.write(text)
end

function getVideosTable()
    local response = http.get("http://" .. domain .. "/v1/library?page=" .. page)
    local decoded = textutils.unserializeJSON(response.readAll())
    local videos = decoded.videos
    local videos_table = {}

    for title, info in pairs(videos) do

        currentYPOS = currentYPOS + 2

        videos_table[title] = {
            video_id = info.video_id,
            file_path = info.file_path,
            coords_table = {
                xMin = 1,
                xMax = 5,
                y = currentYPOS
            }
        }
    end

    return videos_table
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

function writeSongList(videos_table)
    for title, info in pairs(videos_table) do
        monitor.setCursorPos(info.coords_table.xMin, info.coords_table.y)
        monitor.setBackgroundColor(colors.green)
        monitor.write("PLAY")
        monitor.setBackgroundColor(colors.black)
        monitor.write(" " .. title)
    end

end

function main()
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
    writeHeader("Select a song to play!")
    local videosTable = getVideosTable()
    writeSongList(videosTable)

    local waitingForSelection = true
    while waitingForSelection do
        local event, button, x, y = os.pullEvent("monitor_touch")
        for title, info in pairs(videosTable) do
            if x >= info.coords_table.xMin and x <= info.coords_table.xMax and y == info.coords_table.y then
                waitingForSelection = false
                print("Selected: " .. title)
                print("Playing: " .. info.video_id)
                print("File Path: " .. info.file_path)
                shell.run("playSong", '"' .. title .. '"', info.video_id, info.file_path)
            end
        end
    end
end

main()