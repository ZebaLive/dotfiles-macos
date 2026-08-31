local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local popup_width = 250

-- Execute the provider which updates CPU data every 2.0 seconds.
local cpu_colors = string.format("0x%x 0x%x 0x%x 0x%x", colors.blue, colors.yellow, colors.orange, colors.red)
sbar.exec("killall cpu_load >/dev/null; " ..
    "$CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load widgets.cpu 2.0 " .. cpu_colors)

local cpu = sbar.add("graph", "widgets.cpu", 42, {
    position = "right",
    graph = {
        color = colors.blue
    },
    background = {
        height = 22,
        color = {
            alpha = 0
        },
        border_color = {
            alpha = 0
        },
        drawing = true
    },
    icon = {
        string = icons.cpu
    },
    label = {
        string = "cpu ??%",
        font = {
            family = settings.font.numbers,
            style = settings.font.style_map["Bold"],
            size = 9.0
        },
        align = "right",
        padding_right = 0,
        width = 0,
        y_offset = 4
    },
    padding_right = settings.paddings + 6
})

local cpu_bracket = sbar.add("bracket", "widgets.cpu.bracket", {cpu.name}, {
    background = {
        color = colors.bg1,
        border_color = colors.rainbow[#colors.rainbow - 5],
        border_width = 1
    },
    popup = {
        align = "center"
    }
})

local function add_detail(name, title, width, icon_width)
    width = width or popup_width
    icon_width = icon_width or width / 2
    return sbar.add("item", "widgets.cpu.details." .. name, {
        position = "popup." .. cpu_bracket.name,
        width = width,
        icon = {
            string = title .. ":",
            width = icon_width,
            align = "left"
        },
        label = {
            string = "--",
            width = width - icon_width,
            align = "right",
            font = {
                family = settings.font.numbers
            }
        }
    })
end

local total_detail = add_detail("total", "Total")
local user_detail = add_detail("user", "User")
local system_detail = add_detail("system", "System")
local idle_detail = add_detail("idle", "Idle")
local load_detail = add_detail("load", "Load avg", 300, 110)

local function update_cpu_details()
    sbar.exec("sysctl -n vm.loadavg", function(result)
        local load_1, load_5, load_15 = result:match("{%s*([%d.]+)%s+([%d.]+)%s+([%d.]+)%s*}")
        if load_1 then
            load_detail:set({label = load_1 .. " / " .. load_5 .. " / " .. load_15})
        end
    end)
end

update_cpu_details()

local function hide_details()
    cpu_bracket:set({
        popup = {
            drawing = false
        }
    })
end

local function toggle_details()
    local should_draw = cpu_bracket:query().popup.drawing == "off"
    cpu_bracket:set({
        popup = {
            drawing = should_draw
        }
    })
    if should_draw then
        update_cpu_details()
    end
end

cpu:subscribe("mouse.clicked", toggle_details)
cpu:subscribe("mouse.exited.global", hide_details)

sbar.add("item", "widgets.cpu.padding", {
    position = "right",
    width = settings.group_paddings
})
