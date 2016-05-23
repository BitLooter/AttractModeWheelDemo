// Demo layout for the wheel module

class UserConfig {
    </ label="Transition speed", help="Time in MS to change icons", order=1 />
    speed = 200
    </ label="Hilight", help="Hilighting of active item", options="Yes,No", order=2 />
    hilight = "Yes"
    </ label="Number of items", help="Number of items on the wheel", options="1,3,5,7,9,11,13,15", order=3 />
    num_icons = "9"
    </ label="Shadows", help="Enable or disable shadows on wheel items", options="Yes,No", order=4 />
    shadows = "Yes"
    </ label="Curvature", help="Curve of the wheel. Higher numbers make a straighter curve", order=5 />
    curvature = "3.0"
    </ label="Item separation", help="Multiplier to control item distance", order=6 />
    separation = 1.2
    </ label="Artwork", help="Artwork type to use on wheel items", order=7,
       options="wheel,marquee,cover,flyer,snap,title" />
    artwork_type = "wheel"
    </ label="Direction", help="Spin direction of wheel on next item selection", order=8,
       options="clockwise,counterclockwise" />
    direction = "counterclockwise"
    </ label="Debug information", help="Displays information about the wheels", options="Yes,No", order=9 />
    debug = "Yes"
}

fe.layout.width = 1920
fe.layout.height = 1080

fe.do_nut("wheel.nut")

local bg = fe.add_image("white.png", 0, 0, 1920, 1080)
bg.red = 127
bg.green = 127
bg.blue = 127

local config = fe.get_config()
// Convert config values from strings
config.speed = config.speed.tointeger()
config.num_icons = config.num_icons.tointeger()
config.hilight = config.hilight == "Yes"
config.curvature = config.curvature.tofloat()
config.separation = config.separation.tofloat()
config.debug = config.debug == "Yes"
config.shadows = config.shadows == "Yes"

local wheel_left = Wheel(config.curvature, config.num_icons, "left", config.artwork_type)
wheel_left.set_speed(config.speed)
wheel_left.set_icon_separation(config.separation)
wheel_left.set_hilight(config.hilight)
wheel_left.set_direction(config.direction)
wheel_left.set_shadows(config.shadows)
local wheel_right = Wheel(1.5, 3, "right", "cover")
wheel_right.set_speed(config.speed)
wheel_right.set_icon_separation(3)
wheel_right.set_fade_alpha(255, 255)
wheel_right.set_offset_x(200)
wheel_right.set_icon_size(400)
wheel_right.set_hilight(false)

local text_name = fe.add_text("[Title]", 0, fe.layout.height - 100, fe.layout.width, 75)
text_name.align = Align.Right
text_name.style = Style.Bold
local text_system = fe.add_text("[DisplayName]", 0, 25, fe.layout.width, 75)
text_system.align = Align.Right

// Debug info
local debug_x = fe.layout.width/4
local debug_y = 200
local debug_width = fe.layout.width/2
local debug_height = 40
if (config.debug == true) {
    // Both wheels
    fe.add_text("Transition speed: " + wheel_left.transition_ms,
                debug_x, debug_y + debug_height*-3, debug_width, debug_height)
    // Left wheel
    fe.add_text("LEFT WHEEL",
                debug_x, debug_y + debug_height*0, debug_width, debug_height).style = Style.Bold
    fe.add_text("Curvature: " + wheel_left._curvature,
                debug_x, debug_y + debug_height*1, debug_width, debug_height)
    fe.add_text("Number of icons: " + wheel_left.wheel_info.num_icons,
                debug_x, debug_y + debug_height*2, debug_width, debug_height)
    fe.add_text("Icon separation: " + wheel_left.wheel_info.icon_sep,
                debug_x, debug_y + debug_height*3, debug_width, debug_height)
    fe.add_text("Selection hilight: " + wheel_left.wheel_info.do_hilight,
                debug_x, debug_y + debug_height*4, debug_width, debug_height)
    fe.add_text("Artwork type: " + wheel_left.wheel_info.artwork,
                debug_x, debug_y + debug_height*5, debug_width, debug_height)
    fe.add_text("Spin direction: " + (wheel_left.wheel_info.direction == 1 ? "up" : "down"),
                debug_x, debug_y + debug_height*6, debug_width, debug_height)
    // Right wheel
    fe.add_text("RIGHT WHEEL",
                debug_x, debug_y + debug_height*10, debug_width, debug_height).style = Style.Bold
    fe.add_text("Curvature: " + wheel_right._curvature,
                debug_x, debug_y + debug_height*11, debug_width, debug_height)
    fe.add_text("Number of icons: " + wheel_right.wheel_info.num_icons,
                debug_x, debug_y + debug_height*12, debug_width, debug_height)
    fe.add_text("Icon separation: " + wheel_right.wheel_info.icon_sep,
                debug_x, debug_y + debug_height*13, debug_width, debug_height)
    fe.add_text("Selection hilight: " + wheel_right.wheel_info.do_hilight,
                debug_x, debug_y + debug_height*14, debug_width, debug_height)
    fe.add_text("Artwork type: " + wheel_right.wheel_info.artwork,
                debug_x, debug_y + debug_height*15, debug_width, debug_height)
    fe.add_text("Spin direction: " + (wheel_right.wheel_info.direction == 1 ? "up" : "down"),
                debug_x, debug_y + debug_height*16, debug_width, debug_height)
}
