fe.load_module("conveyor");

class WheelIcon extends ConveyorSlot {
	index = null
	wheel_info = null
	
	constructor(icon_index, wheel_info) {
		base.constructor(fe.add_artwork("wheel"))
		this.wheel_info = wheel_info
		this.index = icon_index
		
		m_obj.preserve_aspect_ratio = true
		// Index 0 is the currently selected item
		if (index == 0) {
			m_obj.width = 400
			m_obj.height = 200
			m_obj.alpha = 255
		} else {
			m_obj.width = 300	//TODO: fix size
			m_obj.height = 150
			m_obj.alpha = 63
			m_obj.video_flags = Vid.NoAudio
		}
	}
	
	function on_progress(progress, direction) {
		// "center" progress to be in the middle of its increment
		local progress_centered = progress / (1.0 - (1.0 / wheel_info.num_icons))
		local step = 1.0 / wheel_info.num_icons
		local a = (wheel_info.arc * progress_centered) - wheel_info.arc/2
		m_obj.x = wheel_info.x + cos( a ) * wheel_info.radius
		m_obj.y = wheel_info.y + sin( a ) * wheel_info.radius - m_obj.height/2
		m_obj.rotation = a * 180 / PI
	}
}


class Wheel {
	images = []
	
	/************************
	  curvature (float): How much to curve the icons. Icons are placed on a
	    circle with a diameter equal to the height of the layout mulplied by
		the curvature. Larger numbers make a flatter curve.
	  num_icons (int): Number of icons to place on the curve.
	************************/
	constructor(curvature=2.0, num_icons=9) {
		local radius = fe.layout.height * curvature / 2
		local chord = fe.layout.height
	    local arc_angle = 2 * asin(chord / (2 * radius))
		local apothem = sqrt(pow(radius, 2) - pow(chord/2, 2))
		local wheel_info = {
			x = -apothem
			y = fe.layout.height/2
			radius = radius
			arc = arc_angle
			num_icons = num_icons
			icon_sep = arc_angle/ (num_icons - 1)
		}
		
		local icons = []
		for (local i = -num_icons/2; i <= num_icons/2; i++) {
			icons.append( WheelIcon(i, wheel_info) )
		}

		local c = Conveyor()
		c.set_slots(icons)
		c.transition_ms = 300
	}
}
