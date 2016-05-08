fe.load_module("conveyor");

class WheelIcon extends ConveyorSlot {
	index = null
	angle = null
	wheel_info = null
	
	constructor(icon_index, wheel_info) {
		base.constructor(fe.add_artwork("wheel"))
		this.wheel_info = wheel_info
		index = icon_index
		angle = wheel_info.icon_sep * ((-wheel_info.num_icons/2) + index)
		m_obj.height = 200	//TODO: fix height
	}
	
	function on_progress(progress, direction) {
		local step = 1.0 / wheel_info.num_icons
		local a = angle + (progress - (step * index)) * wheel_info.num_icons * wheel_info.icon_sep
		m_obj.x = wheel_info.x + cos( a ) * wheel_info.radius
		m_obj.y = wheel_info.y + sin( a ) * wheel_info.radius - m_obj.height/2
		m_obj.rotation = a * 180 / PI
	}
}


class Wheel {
	images = []
	
	constructor(curvature=2.0, num_icons=7) {
		local radius = fe.layout.height * curvature / 2
		local chord = fe.layout.height
	    local arc_angle = 2 * asin(chord / (2 * radius))
		local apothem = sqrt(pow(radius, 2) - pow(chord/2, 2))
		local wheel_info = {
			x = -apothem
			y = fe.layout.height/2
			radius = radius
			num_icons = num_icons
			icon_sep = arc_angle/ (num_icons - 1)
		}
		
		local icons = []
		for (local i = -num_icons/2; i <= num_icons/2; i++) {
			icons.append( WheelIcon(i + num_icons/2, wheel_info ) )
		}

		local c = Conveyor()
		c.set_slots(icons)
		c.transition_ms = 300
	}
}
