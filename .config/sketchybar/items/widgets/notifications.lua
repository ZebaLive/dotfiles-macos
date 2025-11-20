local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Create the main notification widget
local notifications = sbar.add("item", "widgets.notifications", {
    position = "right",
    icon = {
        string = icons.notification.bell,
        font = {
            style = settings.font.style_map["Regular"],
            size = 16.0
        },
        color = colors.white
    },
    label = {
        drawing = false
    },
    update_freq = 10
})

-- Function to get notification count
local function update_notifications()
    -- Simply keep the bell icon visible without trying to count
    -- The user can click to check notifications
    notifications:set({
        icon = {
            string = icons.notification.bell,
            color = colors.white
        }
    })
end

-- Subscribe to routine updates
notifications:subscribe("routine", function()
    update_notifications()
end)

-- Subscribe to system wake
notifications:subscribe("system_woke", function()
    update_notifications()
end)

-- Click handler to open Notification Center
notifications:subscribe("mouse.clicked", function()
    -- Use keyboard shortcut to open notification center (Cmd+Shift+N)
    sbar.exec("osascript -e 'tell application \"System Events\" to keystroke \"n\" using {command down, shift down}'")
    -- Update count after opening
    sbar.delay(1, function()
        update_notifications()
    end)
end)

-- Add bracket around the notification widget
sbar.add("bracket", "widgets.notifications.bracket", {notifications.name}, {
    background = {
        color = colors.bg1,
        border_color = colors.red,
        border_width = 1
    }
})

-- Initial update
update_notifications()
