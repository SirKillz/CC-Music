local domain = "https://still-close-bobcat.ngrok-free.app"
local speaker = peripheral.find("speaker")
local dfpwm = require("cc.audio.dfpwm")
local decoder = dfpwm.make_decoder()
local monitor = peripheral.find("monitor")

function getHorizonCenter(text, y)
    local width, height = monitor.getSize()
    local x = math.floor((width - string.len(text)) / 2)
    return x, y
end

function writeHeader(text, yPOS)
    monitor.setCursorPos(getHorizonCenter(text, yPOS)) 
    monitor.write(text)
end

function makeSongRequest(video_link)
    local response = http.post(domain .. "/v1/request/song?video_url=" .. video_link, "")
    local decoded = textutils.unserializeJSON(response.readAll())
    return decoded.message
end

function main()
    term.setCursorPos(1, 1)
    term.clear()
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
    writeHeader("Open the computer below and paste a link!", 1)
    term.write("Enter YouTube video URL:")
    term.setCursorPos(1, 2)
    local video_url = read()
    local message = makeSongRequest(video_url)
    print(message)
    writeHeader(message, 5)
    os.sleep(5)
    shell.run("displayHome")
end

main()