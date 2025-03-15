local GraphicalNote = require("mania/graphic_engine/graphical_note")

class GraphicalLaserNote extends GraphicalNote {
    function update(absolute_delta_time, visual_delta_time, scaled_absolute_delta_time, scaled_visual_delta_time) {
        local x = this.note.position.x + this.position.x
        local y = this.note.position.y + this.position.y
        local z = scaled_visual_delta_time + this.position.z
        this.entity.SetAbsOrigin(Vector(x, y, z))
    }

    function spawn() {
        base.spawn()
        this.entity.SetAbsAngles(QAngle(0, this.note.angle, 0))
    }
}

module <- GraphicalLaserNote