local function loadfile(filename)
    local filepath = hs.spoons.resourcePath(filename)
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
    local contents = loadfile("run-js-on-google-meet.applescript")
    local oldString = "alert%('Hello, world!'%)"
    local newString = jsCode:gsub("\"", "\\\"")
    local modifiedContents = string.gsub(contents, oldString, newString)
    
    local ok, output, _ = hs.osascript.applescript(modifiedContents)
    if not ok then
        print("JS code failed: \n" .. jsCode)
        return ok
    end
    return output
end

local function executeJavaScriptFromFile(action, file)
    print("Performing action: " .. action)
    local jsCode = loadfile(file)
    if not executeJavaScript(jsCode) then
        print("Failed to perform action: " .. action)
        return false
    end
    return true
end

-- JavaScript function to check for element existence and click
local function checkAndClickElementJS(selector)
    return [[
        var element = document.querySelector(']] .. selector .. [[');
        if (element) {
            element.click();
        }
    ]]
end

-- Helper function to execute a JS function with a selector
local function executeCheckAndClickElement(action, selector)
    print("Performing action: " .. action)
    local jsCode = checkAndClickElementJS(selector)
    if not executeJavaScript(jsCode) then
        print("Failed to perform action: " .. action)
        return false
    end
    return true
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

-- Function to join the next meeting
local function joinNextMeeting()
    print("Joining Meeting")
    executeJavaScriptFromFile("Choose and click meeting", "click-on-closest-time.js")
    -- div[data-begin-time]
    hs.timer.doAfter(5, function()
        executeMeetCmd("microphone", "d")
        executeMeetCmd("camera", "e")
        executeCheckAndClickElement("Join actual meeting", 'button[jsname=\"Qx7uuf\"]')
    end)
    return true
end

-- Function to join the next meeting
local function LeaveMeetingAndJoinNext()
    print("Leaving meeting and joinin the next one")
    executeCheckAndClickElement("Leave meeting", 'button[aria-label=\"Leave call\"]')
    hs.timer.doAfter(4, function()
        executeCheckAndClickElement("Really leave meeting", 'button[jsname=\"dqt8Pb\"]')
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

return obj
