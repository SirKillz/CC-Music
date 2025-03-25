local monitor = peripheral.find("monitor")
local width, height = monitor.getSize()
local currentYPOS = 1
local domain = "still-close-bobcat.ngrok-free.app"

-- Capture the command-line arguments into a table.
local args = { ... }
local page = tonumber(args[1])

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

function createButton(text, color, x, y)
    monitor.setCursorPos(x, y)
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

function createPaginationButtons()
    local nextButton = createButton("Next", colors.green, width - 6, height)
    local prevButton = nil

    if page > 1 then
        prevButton = createButton("Prev", colors.orange, width - 12, height)
    end

    return {
        nextButton = nextButton,
        prevButton = prevButton
    }

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
    local homeButton = createButton("Home", colors.red, 1, height)
    local paginationButtons = createPaginationButtons()
    local nextButton = paginationButtons.nextButton
    local prevButton = paginationButtons.prevButton

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

        -- check if the home button was clicked
        if x >= homeButton.xMin and x <= homeButton.xMax and y == homeButton.y then
            waitingForSelection = false
            shell.run("displayHome")
        end

        -- check if the next button was clicked
        if x >= nextButton.xMin and x <= nextButton.xMax and y == nextButton.y then
            waitingForSelection = false
            shell.run("displayLibrary", tostring(page + 1))
        end

        -- check if the prev button was clicked
        if x >= prevButton.xMin and x <= prevButton.xMax and y == prevButton.y then
            waitingForSelection = false
            shell.run("displayLibrary", tostring(page - 1))
        end
    end
end

main()