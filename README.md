# GoogleMeet.spoon

A Hammerspoon spoon designed to enhance Google Meet usage by providing a set of automated controls. These include mic/video toggle, swift meeting switches, and auto-join features, effectively circumventing Google Meet's slower UI.

## Features

- Mic and video toggle.
- Auto-join next scheduled meetings.
- Quick transition to the next meeting.

## Usage

Clone the repo to your Spoons dir, usually `~/.hammerspoon/Spoons`
Then in your init.lua add the following:

```lua
GoogleMeet = hs.loadSpoon("GoogleMeet")
GoogleMeet:bindHotKeys({
    toggleMic={{}, "F1", message="Toggle GMeet Mic"},
    toggleCamera={{"cmd", "alt"}, "s", "s", message="Toggle GMeet Camera"},
    joinNextMeeting={{}, "F3", message="Join next meeting"},
    LeaveMeetingAndJoinNext={{}, "F4", message="Leave current meeting, and join the next one"},
})
```

The above code will bind the following functionalities to their respective key commands:

- toggleMic function to the F1 key. This function toggles the state of the microphone in Google Meet.
- toggleCamera function to the cmd+alt+s key command. This function toggles the state of the camera in Google Meet.
- joinNextMeeting function to the F3 key. This function allows you to join the next scheduled meeting automatically.
- LeaveMeetingAndJoinNext function to the F4 key. This function allows you to leave the current meeting and join the next scheduled meeting seamlessly.