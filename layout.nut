fe.do_nut("wheel.nut")

local w = Wheel(3.0, 9, "left")
//local w = Wheel(3.0, 9, "right")
w.set_speed(100)
w._conveyor.reset_progress()

local text_name = fe.add_text("[Title]", 0, fe.layout.height - 100, fe.layout.width, 75)
text_name.align = Align.Right
text_name.style = Style.Bold
print(text_name.msg_width)
local text_system = fe.add_text("[DisplayName]", 0, 25, fe.layout.width, 75)
text_system.align = Align.Right

// Debug info
local debug_x = fe.layout.width/4
local debug_y = 200
local debug_width = fe.layout.width/2
local debug_height = 50
local debug_curvature = fe.add_text("Curvature: " + w._curvature,
									debug_x, debug_y, debug_width, debug_height)
local debug_curvature = fe.add_text("Number of icons: " + w.wheel_info.num_icons,
									debug_x, debug_y + debug_height*1, debug_width, debug_height)
