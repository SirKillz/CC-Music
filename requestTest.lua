local speaker = peripheral.find("speaker")
if not speaker then
    error("No speaker peripheral found")
end

local dfpwm = require("cc.audio.dfpwm")
local decoder = dfpwm.make_decoder()

-- Your public FastAPI + ngrok URL
local apiEndpoint = "https://4da2-2601-244-417c-22d0-d07c-70fe-bbfa-60b8.ngrok-free.app/get-music"
local youtubeURL = "https://www.youtube.com/watch?v=yMBFdtRbFD0"
local requestURL = apiEndpoint .. "?video_url=" .. textutils.urlEncode(youtubeURL)

print("Requesting audio from API...")
local response = http.get(requestURL)
if not response then
    error("Failed to connect to API.")
end

print("Streaming audio directly to speaker...")

-- Read response in chunks and decode/play immediately
while true do
    local chunk = response.read(16 * 1024)
    if not chunk then break end

    local decoded = decoder(chunk)

    while not speaker.playAudio(decoded) do
        os.pullEvent("speaker_audio_empty")
    end
end

response.close()
print("Playback finished.")
