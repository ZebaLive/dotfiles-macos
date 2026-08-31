local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local popup_width = 250

local ram = sbar.add("graph", "widgets.ram", 42, {
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
        string = icons.ram
    },
    label = {
        string = "ram ??%",
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
    update_freq = 10,
    padding_right = settings.paddings + 6
})

local ram_bracket = sbar.add("bracket", "widgets.ram.bracket", {ram.name}, {
    background = {
        color = colors.bg1,
        border_color = colors.rainbow[#colors.rainbow - 4],
        border_width = 1
    },
    popup = {
        align = "center"
    }
})

local function add_detail(name, title)
    return sbar.add("item", "widgets.ram.details." .. name, {
        position = "popup." .. ram_bracket.name,
        width = popup_width,
        icon = {
            string = title .. ":",
            width = popup_width / 2,
            align = "left"
        },
        label = {
            string = "--",
            width = popup_width / 2,
            align = "right",
            font = {
                family = settings.font.numbers
            }
        }
    })
end

local total_detail = add_detail("total", "Total")
local used_detail = add_detail("used", "Used")
local available_detail = add_detail("available", "Available")
local cache_detail = add_detail("cache", "Cache")
local free_detail = add_detail("free", "Free")
local swap_detail = add_detail("swap", "Swap")
local pressure_detail = add_detail("pressure", "Memory pressure")

local function format_bytes(bytes)
    local gibibyte = 1024 * 1024 * 1024
    if bytes >= gibibyte then
        return string.format("%.1f GiB", bytes / gibibyte)
    end
    return string.format("%.0f MiB", bytes / (1024 * 1024))
end

local function update_memory()
    local command = "vm_stat; printf '__TOTAL__ '; sysctl -n hw.memsize; " ..
        "sysctl vm.swapusage; memory_pressure -Q"
    sbar.exec(command, function(memory_info)
        local page_size = tonumber(memory_info:match("page size of (%d+) bytes"))
        local total_bytes = tonumber(memory_info:match("__TOTAL__ (%d+)"))

        if not page_size or not total_bytes then
            ram:set({label = "ram ??%"})
            return
        end

        local free_pages = tonumber(memory_info:match("Pages free:%s+(%d+)%."))
        local inactive_pages = tonumber(memory_info:match("Pages inactive:%s+(%d+)%."))
        if not free_pages or not inactive_pages then
            ram:set({label = "ram ??%"})
            return
        end

        local available_bytes = (free_pages + inactive_pages) * page_size
        local used_bytes = total_bytes - available_bytes
        local file_backed_pages = tonumber(memory_info:match("File%-backed pages:%s+(%d+)")) or 0
        local purgeable_pages = tonumber(memory_info:match("Pages purgeable:%s+(%d+)")) or 0
        local cache_bytes = (file_backed_pages + purgeable_pages) * page_size
        local load = math.max(0, math.min(100, math.floor((total_bytes - available_bytes) / total_bytes * 100 + 0.5)))
        local color = colors.blue
        if load > 60 then
            if load < 75 then
                color = colors.yellow
            elseif load < 90 then
                color = colors.orange
            else
                color = colors.red
            end
        end

        ram:push({load / 100})
        ram:set({
            graph = {
                color = color
            },
            label = "ram " .. load .. "%"
        })

        total_detail:set({label = format_bytes(total_bytes)})
        used_detail:set({label = format_bytes(used_bytes)})
        available_detail:set({label = format_bytes(available_bytes)})
        cache_detail:set({label = format_bytes(cache_bytes)})
        free_detail:set({label = format_bytes(free_pages * page_size)})

        local swap_total, swap_used = memory_info:match("total = ([%d.]+)M%s+used = ([%d.]+)M")
        if swap_total and swap_used then
            swap_detail:set({label = swap_used .. " / " .. swap_total .. " MiB"})
        end

        local pressure = memory_info:match("memory free percentage: (%d+)%%")
        if pressure then
            pressure_detail:set({label = pressure .. "% available"})
        end
    end)
end

ram:subscribe({"routine", "system_woke"}, update_memory)
update_memory()

local function hide_details()
    ram_bracket:set({
        popup = {
            drawing = false
        }
    })
end

local function toggle_details()
    local should_draw = ram_bracket:query().popup.drawing == "off"
    ram_bracket:set({
        popup = {
            drawing = should_draw
        }
    })
    if should_draw then
        update_memory()
    end
end

ram:subscribe("mouse.clicked", toggle_details)
ram:subscribe("mouse.exited.global", hide_details)

sbar.add("item", "widgets.ram.padding", {
    position = "right",
    width = settings.group_paddings
})