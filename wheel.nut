fe.load_module("conveyor");

class WheelIcon extends ConveyorSlot {
    index = null
    wheel_info = null
    base_height = null
    base_width = null
    selected_scale = 1.5
    fade_start = null
    fade_end = null
    fade_inc = null
    
    t = null
    
    constructor(icon_index, wheel_info) {
        base.constructor(fe.add_artwork("wheel"))
        this.wheel_info = wheel_info
        this.index = icon_index
        
        this.fade_inc = (1.0 / wheel_info.num_icons)
        this.fade_start = (index + wheel_info.num_icons/2).tofloat() / wheel_info.num_icons
        this.fade_end = fade_start + fade_inc
        
        m_obj.preserve_aspect_ratio = true
        this.base_height = fe.layout.height / wheel_info.num_icons * 1.5
        this.base_width = base_height * 2
        // Index 0 is the selection item
        if (index == 0) {
            m_obj.width = base_width * selected_scale
            m_obj.height = base_height * selected_scale
            m_obj.alpha = 255
            m_obj.zorder = 1000     //TODO: zorder doesn't work here
            
            t = fe.add_text("<null>", 0, 0, fe.layout.width, 50)
            t.align = Align.Left
        } else {
            m_obj.width = base_width
            m_obj.height = base_height
            m_obj.alpha = 63
            m_obj.video_flags = Vid.NoAudio
        }
    }
    
    function on_progress(progress, direction) {
        // "center" progress to be in the middle of its increment
        local progress_centered = progress + 1.0 / (wheel_info.num_icons*2)
        local step = 1.0 / wheel_info.num_icons
        local a = (wheel_info.arc * progress_centered) - wheel_info.arc/2
        //local s = fe.layout.width - base_width
        local x = wheel_info.x + cos( a ) * wheel_info.radius + wheel_info.offset_x
        if (wheel_info.side == "left") {
            m_obj.x = x
			m_obj.rotation = a * 180 / PI
        } else {
            m_obj.x = fe.layout.width - x - (base_width * selected_scale)
			m_obj.rotation = -a * 180 / PI
        }
        m_obj.y = wheel_info.y + sin( a ) * wheel_info.radius  + wheel_info.offset_y - m_obj.height/2
        //m_obj.rotation = a * 180 / PI
        //m_obj.rotation = -a * 180 / PI
        // Selection icon gets special treatment
        if (index == 0) {
            local fade_amount = (fade_start + fade_inc/2 - progress_centered) * wheel_info.num_icons*2
            m_obj.alpha = 255 - abs(192.0 * fade_amount)
            m_obj.height = base_height*selected_scale - abs(base_height*(selected_scale-1) * (fade_amount))
            m_obj.width = m_obj.height * 2
            t.msg = 255 - abs(192.0 * fade_amount)
        }
    }
}


class Wheel {
    images = []
    wheel_info = null
	_curvature = null
    _conveyor = null
    
    /************************
      curvature (float): How much to curve the icons. Icons are placed on a
        circle with a diameter equal to the height of the layout mulplied by
        the curvature. Larger numbers make a flatter curve.
      num_icons (int): Number of icons to place on the curve.
    ************************/
    constructor(curvature=2.0, num_icons=7, side="left") {
        local radius = fe.layout.height * curvature / 2
        local chord = fe.layout.height
        local arc_angle = 2 * asin(chord / (2 * radius))
        local apothem = sqrt(pow(radius, 2) - pow(chord/2, 2))
        wheel_info = {
            x = -apothem
            y = fe.layout.height/2
            offset_x = 0
            offset_y = 0
            radius = radius
            arc = arc_angle
            num_icons = num_icons
            icon_sep = arc_angle/ (num_icons - 1)
            side = side
        }
        
        local icons = []
        for (local i = -num_icons/2; i <= num_icons/2; i++) {
            icons.append( WheelIcon(i, wheel_info) )
        }
		
		_curvature = curvature

        _conveyor = Conveyor()
        _conveyor.set_slots(icons)
        _conveyor.transition_ms = 300
    }
    
    // Sets transition speed in ms
    function set_speed(speed) {
        _conveyor.transition_ms = speed
    }
    
    // Set amount wheel is offset
    function set_offset_x(offset) {
        wheel_info.offset_x = offset
    }
    
    function set_offset_y(offset) {
        wheel_info.offset_y = offset
    }
    
    // Forces the wheel to draw the icons again
    function rerender() {
        _conveyor.reset_progress()
    }
}
