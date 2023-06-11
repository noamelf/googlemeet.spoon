logger = hs.logger.new("GoogleMeet", "info")

local function loadfile(filename)
    local filepath = hs.spoons.resourcePath(filename)
    local file = io.open(filepath, "r")
    if file == nil then
        logger.e("Could not open file: " .. filename)
        return
    end
    local contents = file:read("*a")
    file:close()
    return contents
end

-- Function to execute JavaScript via AppleScript
local function executeJavaScript(jsCode)
    local contents = loadfile("run-js-on-google-meet.applescript")
    local oldString = "alert%('Hello, world!'%)"
    local newString = jsCode:gsub('"', '\\"')
    local modifiedContents = string.gsub(contents, oldString, newString)

    -- logger.d("Applescript: \n" .. modifiedContents)

    local ok, output, _ = hs.osascript.applescript(modifiedContents)
    logger.d("ok: " .. ok .. " output: " .. output .. " raw output: " .. _)
    if not ok then
        logger.e("Applescript failed: \n" .. modifiedContents)
        return ok
    end
    return output
end

local function executeJavaScriptFromFile(file)
    local jsCode = loadfile(file)
    return executeJavaScript(jsCode)
end

-- Helper function to execute a JS function with a selector
local function clickElement(selector)
    logger.d("Clicking element: " .. selector)
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
    logger.i("Toggled " .. toggleFeature .. " on Google Meet")
    return true
end

local function toggleMic()
    logger.i('Toggle Microphone')
    if not clickElement('button[aria-label="Turn off microphone (⌘ + d)"]') then
        clickElement('button[aria-label="Turn on microphone (⌘ + d)"]')
    end
end

local function toggleCamera()
    logger.i('Toggle camera')
    if not clickElement('button[aria-label="Turn off camera (⌘ + e)"]') then
        clickElement('button[aria-label="Turn on camera (⌘ + e)"]')
    end
end

local function joinActualMeeting()
    clickElement('button[jsname="Qx7uuf"]')
end

-- Function to join the next meeting
local function joinNextMeeting()
    logger.i("Joining Meeting")
    if executeJavaScriptFromFile("click-on-closest-time.js") then
        hs.timer.doAfter(5, joinActualMeeting)
        return true
    else
        logger.e('Failed to click on the next meeting')
    end

    return false
end

local function joinMeetingOnSchedule()
    logger.i("Checking if meeting started, if started, click it")
    if executeJavaScriptFromFile("click-on-meeting-starting.js") then
        hs.timer.doAfter(7, joinActualMeeting)
        return true
    end
    return false
end

-- Function to join the next meeting
local function LeaveMeetingAndJoinNext()
    logger.i("Leaving meeting and joinin the next one")
    clickElement('button[aria-label="Leave call"]')
    hs.timer.doAfter(4, function()
        clickElement('button[jsname="dqt8Pb"]')
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
        toggleMic = toggleMic,
        toggleCamera = toggleCamera,
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

function obj:setLogLevel(level)
    logger.setLogLevel(level)
    return self
end

return obj
