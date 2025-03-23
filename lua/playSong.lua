local domain = "https://still-close-bobcat.ngrok-free.app"
local speaker = peripheral.find("speaker")
local dfpwm = require("cc.audio.dfpwm")
local decoder = dfpwm.make_decoder()

-- Capture the command-line arguments into a table.
local args = { ... }

-- You can then extract them by index:
local title = args[1]
local video_id = args[2]
local file_path = args[3]

function getSongContent()
    local response = http.get(domain .. "/v1/song?video_id=" .. video_id)
    return response
end

function playSong(songData)
    while true do
        local chunk = songData.read(16 * 1024)
        if not chunk then break end
    
        local decoded = decoder(chunk)
    
        while not speaker.playAudio(decoded) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end

function main()
    if not title or not video_id or not file_path then
        print("Missing arguments! Expected: title, video_id, file_path")
        return
    end

    -- Use the variables as needed.
    print("Title:", title)
    print("Video ID:", video_id)
    print("File Path:", file_path)
    local songData = getSongContent()
    playSong(songData)
end

main()