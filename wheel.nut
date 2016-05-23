fe.load_module("conveyor");

//TODO: fix weird zoom on hilight icon on right wheels
//TODO: Default image
//TODO: icon shadows
//TODO: Use vertex shaders for hardware acceleration
//TODO: fix selected icon centering
//TODO: default maximum icon size

class WheelIcon extends ConveyorSlot {
    index = null
    type = null
    wheel_info = null
    selected_scale = 1.5
    fade_start = null
    fade_end = null
    fade_inc = null
    artwork_image = null
    artwork_text = null
    last_item = null
    
    constructor(icon_index, wheel_info) {
        index = icon_index
        this.wheel_info = wheel_info
        // Detect to use image or text
        artwork_image = fe.add_artwork(wheel_info.artwork)
        artwork_image.preserve_aspect_ratio = true
        _set_icon_type()
        artwork_text = fe.add_text("[Title]", 0, 50, 400, 200)
        artwork_text.charsize = artwork_text.height/4
        artwork_text.word_wrap = true
        artwork_text.index_offset = icon_index
        artwork_text.bg_green = 255
        artwork_text.bg_alpha = 127
        base.constructor(artwork_image)
        
        this.fade_inc = (1.0 / wheel_info.num_icons)
        this.fade_start = (index + wheel_info.num_icons/2).tofloat() / wheel_info.num_icons
        this.fade_end = fade_start + fade_inc
        
        // Index 0 is the selection item
        if (index == 0) {
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
        // Correct for rotation centered at top left rather than center
        x = x + sin(angle) * artwork_image.height / 2
        local y = wheel_info.y + sin( angle ) * wheel_info.radius  + wheel_info.offset_y - artwork_image.height/2
        local rotation = null
        if (wheel_info.do_rotate) {
            rotation = angle * 180 / PI
        } else {
            rotation = 0
        }
        
        if (type == "image") {
            artwork_image.visible = true
            artwork_text.visible = false
        } else {
            artwork_image.visible = false
            artwork_text.visible = true
        }
        
        if (wheel_info.side == "right") {
            x = fe.layout.width - x - artwork_image.width + wheel_info.offset_x*2
            // Rotation is centered at top left, this corrects for right rotation
            y = y + sin(angle) * artwork_image.width
            rotation = -rotation
        }
        
        artwork_image.x = artwork_text.x = x
        artwork_image.y = artwork_text.y = y
        artwork_image.rotation = artwork_text.rotation = rotation
        
        // Selection icon gets special treatment
        if (index == 0 && wheel_info.do_hilight) {
            artwork_image.zorder = artwork_text.zorder = 1000
            local fade_amount = (fade_start + fade_inc/2 - progress_centered) * wheel_info.num_icons*2
            local alpha = wheel_info.fadein_alpha - abs((wheel_info.fadein_alpha - wheel_info.fadeout_alpha) * fade_amount)
            local height = wheel_info.base_height*selected_scale - abs(wheel_info.base_height*(selected_scale-1) * fade_amount)
            local width = height * 2
            artwork_image.width = artwork_text.width = width
            artwork_image.height = artwork_text.height = height
            artwork_image.alpha = artwork_text.alpha = alpha
            artwork_text.charsize = height/4
        }
    }
    
    function _artwork_available(arttype, offset) {
        return fe.get_art(arttype, offset) != ""
    }
    
    function _set_icon_type(icon_index=null) {
        local art_index
        if (icon_index == null) {
            art_index = index
        } else {
            art_index = icon_index
        }
        
        if (_artwork_available(wheel_info.artwork, art_index)) {
            type = "image"
        } else {
            type = "text"
        }
    }
    
    function swap(other) {
        //BUG: This doesn't get called on a wheel with one icon, so the type never changes
        base.swap(other)
        _set_icon_type(other.index)
    }
    
    function _set_baseicon_attributes() {
        artwork_image.width = artwork_text.width = wheel_info.base_width
        artwork_image.height = artwork_text.height = wheel_info.base_height
        artwork_image.alpha = artwork_text.alpha = wheel_info.fadeout_alpha
        if (type == "image") {
            artwork_image.video_flags = Vid.NoAudio
        }
    }
    
    function _set_hilight_attributes() {
        if (wheel_info.do_hilight) {
            artwork_image.width = artwork_text.width = wheel_info.base_width * selected_scale
            artwork_image.height = artwork_text.height = wheel_info.base_height * selected_scale
            artwork_image.alpha = artwork_text.alpha = wheel_info.fadein_alpha
        } else {
            _set_baseicon_attributes()
        }
    }
}


class Wheel extends Conveyor {
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
      side (string): Side of the layout, "left" or "right"
      artwork (string): Artwork type to use as icons
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
            //do_hilight = true
        }
        set_offset_x(0)
        set_offset_y(0)
        set_hilight(true)
        set_icon_separation(1.0)
        set_rotation(true)
        set_direction("counterclockwise")
        set_icon_size(fe.layout.height / num_icons * 1.5)
        set_fade_alpha(127, 255)
        
        _icons = []
        for (local i = -num_icons/2; i <= num_icons/2; i++) {
            local icon = WheelIcon(i, wheel_info)
            _icons.append( icon )
            if (i == 0) _hilighticon = icon
        }
        
        _curvature = curvature

        //_conveyor = Conveyor()
		base.constructor()
        set_slots(_icons)
		
    }
    
    // Sets transition speed in ms
    function set_speed(speed) {
        transition_ms = speed
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
        if (m_objs.len() > 0) {
            _reset_icons()
            reset_progress()
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
        if (_hilighticon != null) {
            _hilighticon._set_hilight_attributes()
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
        if (direction == "counterclockwise") {
            wheel_info.direction <- 1
        } else if (direction == "clockwise") {
            wheel_info.direction <- -1
        } else {
            //TODO: raise an error here
            wheel_info.direction <- 1/0
        }
		if (wheel_info.side == "right") {
			wheel_info.direction *= -1
		}
        rerender()
    }
}
