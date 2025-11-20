local settings = require("settings")
local colors = require("colors")

-- Padding item required because of bracket
sbar.add("item", {
    position = "right",
    width = settings.group_paddings
})

local cal = sbar.add("item", {
    icon = {
        color = colors.white,
        padding_left = 8,
        padding_right = 5,
        font = {
            style = settings.font.style_map["Regular"],
            size = 16.0
        }
    },
    label = {
        color = colors.white,
        padding_right = 8,
        padding_left = 0,
        align = "left",
        font = {
            family = settings.font.numbers,
            style = settings.font.style_map["Bold"],
            size = 12.0
        }
    },
    position = "right",
    update_freq = 30,
    padding_left = 1,
    padding_right = 1,
    background = {
        color = colors.bg2,
        border_color = colors.rainbow[#colors.rainbow],
        border_width = 1
    }
})

-- Double border for calendar using a single item bracket
-- sbar.add("bracket", { cal.name }, {
--   background = {
--     color = colors.transparent,
--     height = 30,
--     border_color = colors.grey,
--   }
-- })

cal:subscribe({"forced", "routine", "system_woke"}, function(env)
    cal:set({
        icon = "􀉉",
        label = os.date("%Y-%m-%d %H:%M")
    })
end)

-- Click handler to open Notification Center
cal:subscribe("mouse.clicked", function()
    -- Use keyboard shortcut to open notification center (Cmd+Shift+N)
    sbar.exec("osascript -e 'tell application \"System Events\" to keystroke \"n\" using {command down, shift down}'")
end)
