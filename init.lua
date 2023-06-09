local function loadfile(filename)
    filepath = hs.spoons.resourcePath(filename)
    local file = io.open(filepath, "r")
    if file == nil then
        print("Could not open file: " .. filename)
        return
    end
    local contents = file:read("*a")
    file:close()
    return contents
end

-- Function to execute JavaScript via AppleScript
local function executeJavaScript(jsCode)
    local oldString = "alert%('Hello, world!'%)"
    local newString = jsCode:gsub("\"", "\\\"")
    local contents = loadfile("run-js-on-google-meet.applescript")

    local modifiedContents = string.gsub(contents, oldString, newString)

    local result, object, descriptor = hs.osascript.applescript(modifiedContents)
    if not result then
        print("JS code failed: \n" .. jsCode)
    end
    print(ok, clicked)
    return (ok and clicked)
end

local function executeJavaScriptFromFile(file)
    local jsCode = loadfile(file)
    return executeJavaScript(jsCode)
end

-- Helper function to execute a JS function with a selector
local function clickElement(selector)
    local contents = loadfile("click-element.js")
    local jsCode = string.gsub(contents, "<<selector>>", selector)
    return executeJavaScript(jsCode)
end

-- Utility function to execute Google Meet commands
local function executeMeetCmd(toggleFeature, shortcut)
    hs.application.launchOrFocus("Google Meet")
    hs.timer.doAfter(0.1, function()
        hs.eventtap.keyStroke({"cmd"}, shortcut)
    end)
    print("Toggled " .. toggleFeature .. " on Google Meet")
    return true
end

local function joinActualMeeting()
    executeMeetCmd("microphone", "d")
    executeMeetCmd("camera", "e")
    clickElement('button[jsname=\"Qx7uuf\"]')
end

-- Function to join the next meeting
local function joinNextMeeting()
    print("Joining Meeting")
    if executeJavaScriptFromFile("click-on-closest-time.js") then
        hs.timer.doAfter(5, joinActualMeeting)
        return true
    end
    return false
end

local function joinMeetingOnSchedule()
    print("Checking if meeting started, if started, click it")
    if executeJavaScriptFromFile("click-on-meeting-starting.js") then
        hs.timer.doAfter(5, joinActualMeeting)
        return true
    end
    return false
end

-- Function to join the next meeting
local function LeaveMeetingAndJoinNext()
    print("Leaving meeting and joinin the next one")
    clickElement('button[aria-label=\"Leave call\"]')
    hs.timer.doAfter(4, function()
        clickElement('button[jsname=\"dqt8Pb\"]')
        hs.timer.doAfter(4, function()
            joinNextMeeting()
        end)
    end)
    return true
end

-- Create the Spoon object
local obj = {}

-- Metadata
obj.name = "GoogleMeet"
obj.version = "1.0"
obj.author = "Noam Elfanbaum"

function obj:bindHotKeys(mapping)
    local spec = {
        toggleMic = hs.fnutils.partial(executeMeetCmd, "microphone", "d"),
        toggleCamera = hs.fnutils.partial(executeMeetCmd, "camera", "e"),
        joinNextMeeting = joinNextMeeting,
        LeaveMeetingAndJoinNext = LeaveMeetingAndJoinNext
    }
    hs.spoons.bindHotkeysToSpec(spec, mapping)
    return self
end

function obj:start()
    hs.timer.new(10, joinMeetingOnSchedule):start()
    return self
end

return obj
