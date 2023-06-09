on contains_substring(theString, theSubstring)
    set theString_length to length of theString
    set theSubstring_length to length of theSubstring
    if theString_length is less than theSubstring_length then return false
    repeat with i from 1 to theString_length - theSubstring_length + 1
        if text i thru (i + theSubstring_length - 1) of theString is theSubstring then
            return true
        end if
    end repeat
    return false
end contains_substring

tell application "Google Chrome"
    set windowList to every window
    repeat with aWindow in windowList
        set tabList to every tab of aWindow
        repeat with aTab in tabList
            if my contains_substring(title of aTab, "Meet") then
                tell aTab
                    return execute javascript "alert('Hello, world!')"
                end tell
                exit repeat
            end if
        end repeat
    end repeat
end tell
