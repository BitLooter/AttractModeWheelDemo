fe.do_nut("wheel.nut")

Wheel()
local text_name = fe.add_text("[Title]", 0, fe.layout.height - 100, fe.layout.width, 75)
text_name.align = Align.Right
text_name.style = Style.Bold
print(text_name.msg_width)
local text_system = fe.add_text("[DisplayName]", 0, 25, fe.layout.width, 75)
text_system.align = Align.Right
