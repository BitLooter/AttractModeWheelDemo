fe.do_nut("wheel.nut")

local wheel_left = Wheel(3.0, 9, "left")
local wheel_right = Wheel(3.0, 1, "right", "cover")
wheel_right.set_fade_alpha(255, 255)
wheel_right.set_offset_x(150)
wheel_right.set_icon_size(300)
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
local debug_curvature = fe.add_text("LEFT WHEEL",
                                    debug_x, debug_y - debug_height, debug_width, debug_height)
debug_curvature.style = Style.Bold
local debug_curvature = fe.add_text("Curvature: " + wheel_left._curvature,
                                    debug_x, debug_y, debug_width, debug_height)
local debug_numicons = fe.add_text("Number of icons: " + wheel_left.wheel_info.num_icons,
                                    debug_x, debug_y + debug_height*1, debug_width, debug_height)
local debug_side = fe.add_text("Wheel side: " + wheel_left.wheel_info.side,
                               debug_x, debug_y + debug_height*2, debug_width, debug_height)
local debug_speed = fe.add_text("Transition speed: " + wheel_left._conveyor.transition_ms,
                                debug_x, debug_y + debug_height*3, debug_width, debug_height)
local debug_speed = fe.add_text("Rotation: " + wheel_left.wheel_info.do_rotate,
                                debug_x, debug_y + debug_height*4, debug_width, debug_height)
local debug_speed = fe.add_text("Selection hilight: " + wheel_left.wheel_info.do_hilight,
                                debug_x, debug_y + debug_height*5, debug_width, debug_height)
local debug_speed = fe.add_text("Artwork: " + wheel_left.wheel_info.artwork,
                                debug_x, debug_y + debug_height*6, debug_width, debug_height)
