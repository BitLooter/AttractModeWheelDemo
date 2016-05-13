fe.load_module("conveyor");

//TODO: Replace missing logos with text
//TOOD: fix weird zoom on hilight icon on right wheels

class WheelIcon extends ConveyorSlot {
    index = null
    wheel_info = null
    selected_scale = 1.5
    fade_start = null
    fade_end = null
    fade_inc = null
    
    constructor(icon_index, wheel_info) {
        local artwork = fe.add_artwork(wheel_info.artwork)
        //local artwork = fe.add_surface(400, 200)
        //local artwork_text = artwork.add_text("[Name]", 0, 50, 400, 50)
        //artwork_text.word_wrap = true
        //artwork_text.index_offset = icon_index
        
        base.constructor(artwork)
        this.wheel_info = wheel_info
        this.index = icon_index
        
        this.fade_inc = (1.0 / wheel_info.num_icons)
        this.fade_start = (index + wheel_info.num_icons/2).tofloat() / wheel_info.num_icons
        this.fade_end = fade_start + fade_inc
        
        m_obj.preserve_aspect_ratio = true
        // Index 0 is the selection item
        if (index == 0 && wheel_info.do_hilight) {
            _set_hilight_attributes()
        } else {
            _set_baseicon_attributes()
        }
    }
    
    function on_progress(progress, direction) {
        // "center" progress to be in the middle of its increment
        local progress_centered = progress + 1.0 / (wheel_info.num_icons*2)
        local step = 1.0 / wheel_info.num_icons
        local angle = ((wheel_info.arc * progress_centered) - wheel_info.arc/2) *
					  wheel_info.icon_sep * wheel_info.direction
        local x = wheel_info.x + cos( angle ) * wheel_info.radius + wheel_info.offset_x
        local y = wheel_info.y + sin( angle ) * wheel_info.radius  + wheel_info.offset_y - m_obj.height/2
        local rotation = null
        if (wheel_info.do_rotate) {
            rotation = m_obj.rotation = angle * 180 / PI
        } else {
            rotation = 0
        }
        if (wheel_info.side == "left") {
            m_obj.x = x
            m_obj.y = y
            m_obj.rotation = rotation
        } else {
            m_obj.x = fe.layout.width - x - m_obj.width + wheel_info.offset_x*2
            // Rotation is from top left, this corrects for right rotation
            m_obj.y = y + sin(angle) * m_obj.height * 2
            m_obj.rotation = -rotation
        }
        // Selection icon gets special treatment
        if (index == 0 && wheel_info.do_hilight) {
            m_obj.zorder = 10     //TODO: zorder doesn't work here
            local fade_amount = (fade_start + fade_inc/2 - progress_centered) * wheel_info.num_icons*2
            m_obj.alpha = wheel_info.fadein_alpha - abs((wheel_info.fadein_alpha - wheel_info.fadeout_alpha) * fade_amount)
            m_obj.height = wheel_info.base_height*selected_scale - abs(wheel_info.base_height*(selected_scale-1) * fade_amount)
            m_obj.width = m_obj.height * 2
        }
    }
    
    function _set_baseicon_attributes() {
        m_obj.width = wheel_info.base_width
        m_obj.height = wheel_info.base_height
        m_obj.alpha = wheel_info.fadeout_alpha
        m_obj.video_flags = Vid.NoAudio
    }
    
    function _set_hilight_attributes() {
        m_obj.width = wheel_info.base_width * selected_scale
        m_obj.height = wheel_info.base_height * selected_scale
        m_obj.alpha = wheel_info.fadein_alpha
        m_obj.zorder = 10     //TODO: zorder doesn't work here
    }
}


class Wheel {
    images = []
    wheel_info = null
    _hilighticon = null
    _curvature = null
    _conveyor = null
    _icons = null
    _default_sep = null
    
    /************************
      curvature (float): How much to curve the icons. Icons are placed on a
        circle with a diameter equal to the height of the layout mulplied by
        the curvature. Larger numbers make a flatter curve.
      num_icons (int): Number of icons to place on the curve.
    ************************/
    constructor(curvature=2.0, num_icons=7, side="left", artwork="wheel") {
        local radius = fe.layout.height * curvature / 2
        local chord = fe.layout.height
        local arc_angle = 2 * asin(chord / (2 * radius))
        local apothem = sqrt(pow(radius, 2) - pow(chord/2, 2))
        _default_sep = arc_angle / (num_icons - 1)
        wheel_info = {
            x = -apothem
            y = fe.layout.height/2
            radius = radius
            arc = arc_angle
            artwork = artwork
            num_icons = num_icons
            side = side
            do_hilight = true
        }
        set_offset_x(0)
        set_offset_y(0)
        set_icon_separation(1.0)
        set_rotation(true)
		set_direction("down")
        set_icon_size(fe.layout.height / num_icons * 1.5)
        set_fade_alpha(127, 255)
        
        //local icons = []
        _icons = []
        for (local i = -num_icons/2; i <= num_icons/2; i++) {
            local icon = WheelIcon(i, wheel_info)
            _icons.append( icon )
            if (i == 0) _hilighticon = icon
        }
        
        _curvature = curvature

        _conveyor = Conveyor()
        _conveyor.set_slots(_icons)
    }
    
    // Sets transition speed in ms
    function set_speed(speed) {
        _conveyor.transition_ms = speed
    }
    
    // Recalculates icon attributes
    function _reset_icons() {
        foreach(icon in _icons) {
            icon._set_baseicon_attributes()
        }
        _hilighticon._set_hilight_attributes()
    }
    
    // Forces the wheel to draw the icons again
    function rerender() {
        if ("reset_progress" in _conveyor) {
            _reset_icons()
            _conveyor.reset_progress()
        }
    }
    
    // Set amount wheel is offset
    function set_offset_x(offset) {
        wheel_info.offset_x <- offset
        rerender()
    }
    
    function set_offset_y(offset) {
        wheel_info.offset_y <- offset
        rerender()
    }
    
    // Enable/disable icon rotation
    function set_rotation(yesorno) {
        wheel_info.do_rotate <- yesorno
        rerender()
    }
    
    // Enable/disable selection icon hilight
    function set_hilight(do_hilight) {
        wheel_info.do_hilight <- do_hilight
        if (do_hilight) {
            _hilighticon._set_hilight_attributes()
        } else {
            _hilighticon._set_baseicon_attributes()
        }
        rerender()
    }
    
    // Sets amount hilight icon will scale relative to base icon height
    function set_hilight_scale(amount) {
        _hilighticon.selected_scale = amount
        rerender()
    }
    
    // Sets height of the base icon in layout units
    function set_icon_size(size) {
        wheel_info.base_height <- size
        wheel_info.base_width <- size * 2
        rerender()
    }
    
    // Set fade opacity
    function set_fade_alpha(min_fade, max_fade) {
        wheel_info.fadeout_alpha <- min_fade
        wheel_info.fadein_alpha <- max_fade
        rerender()
    }
    
    // Set distance between icons
    function set_icon_separation(multiplier) {
        wheel_info.icon_sep <- multiplier
        rerender()
    }
	
	// Sets spin direction
	function set_direction(direction) {
		if (direction == "down") {
			wheel_info.direction <- 1
		} else if (direction == "up") {
			wheel_info.direction <- -1
		} else {
			//TODO: raise an error here
			wheel_info.direction <- 1/0
		}
		rerender()
	}
}
