local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Add keyboard layout item
local keyboard_layout = sbar.add("item", "widgets.keyboard_layout", {
    position = "right",
    update_freq = 1,
    icon = {
        string = icons.keyboard or "󰌌",
        padding_left = 8,
        padding_right = 4,
        color = colors.grey,
        font = {
            style = settings.font.style_map["Regular"],
            size = 14.0
        }
    },
    label = {
        string = "US",
        padding_right = 8,
        color = colors.white,
        font = {
            family = settings.font.text,
            style = settings.font.style_map["Semibold"],
            size = 12.0
        }
    },
    background = {
        color = colors.bg1,
        border_color = colors.rainbow[#colors.rainbow - 4],
        border_width = 1
    }
})

-- Function to get current keyboard layout
local function update_keyboard_layout()
    sbar.exec([[defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | grep -A2 'KeyboardLayout Name' | grep -v 'KeyboardLayout Name' | sed 's/[^a-zA-Z0-9]//g']], function(layout)
        -- Clean up the result and get first non-empty line
        local result = layout:match("^%s*(.-)%s*$")
        
        -- If the above fails, try alternative method
        if result == "" or result == nil then
            sbar.exec([[defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID | awk -F'.' '{print $NF}']], function(alt_layout)
                result = alt_layout:match("^%s*(.-)%s*$")
                if result ~= "" and result ~= nil then
                    keyboard_layout:set({ label = result:upper() })
                end
            end)
        else
            keyboard_layout:set({ label = result:upper() })
        end
    end)
end

-- Update on routine update
keyboard_layout:subscribe("routine", update_keyboard_layout)

-- Update immediately
update_keyboard_layout()

-- Subscribe to input source change events (this requires a helper script)
keyboard_layout:subscribe("input_source_change", update_keyboard_layout)
