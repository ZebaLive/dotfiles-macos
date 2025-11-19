-- Catppuccin Mocha Color Palette
return {
    -- Base Catppuccin Mocha colors
    rosewater = 0xfff5e0dc,
    flamingo = 0xfff2cdcd,
    pink = 0xfff5c2e7,
    mauve = 0xffcba6f7,
    red = 0xfff38ba8,
    maroon = 0xffeba0ac,
    peach = 0xfffab387,
    yellow = 0xfff9e2af,
    green = 0xffa6e3a1,
    teal = 0xff94e2d5,
    sky = 0xff89dceb,
    sapphire = 0xff74c7ec,
    blue = 0xff89b4fa,
    lavender = 0xffb4befe,
    
    -- Text colors
    text = 0xffcdd6f4,
    subtext1 = 0xffbac2de,
    subtext0 = 0xffa6adc8,
    
    -- Surface colors
    overlay2 = 0xff9399b2,
    overlay1 = 0xff7f849c,
    overlay0 = 0xff6c7086,
    surface2 = 0xff585b70,
    surface1 = 0xff45475a,
    surface0 = 0xff313244,
    
    -- Base colors
    base = 0xff1e1e2e,
    mantle = 0xff181825,
    crust = 0xff11111b,
    
    -- Legacy aliases for compatibility
    black = 0xff11111b,
    white = 0xffcdd6f4,
    orange = 0xfffab387,
    magenta = 0xffcba6f7,
    grey = 0xff6c7086,
    transparent = 0x00000000,

    bar = {
        bg = 0xd01e1e2e,  -- base with transparency
        border = 0xff1e1e2e
    },
    popup = {
        bg = 0xc01e1e2e,  -- base with transparency
        border = 0xff6c7086  -- overlay0
    },
    bg1 = 0xff313244,  -- surface0
    bg2 = 0xff45475a,  -- surface1

    -- Catppuccin Mocha rainbow
    rainbow = {0xfff38ba8, 0xfffab387, 0xfff9e2af, 0xffa6e3a1, 0xff94e2d5, 0xff89dceb, 0xff74c7ec, 0xff89b4fa,
               0xffb4befe, 0xffcba6f7, 0xfff5c2e7, 0xfff2cdcd},

    with_alpha = function(color, alpha)
        if alpha > 1.0 or alpha < 0.0 then
            return color
        end
        return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
    end
}
