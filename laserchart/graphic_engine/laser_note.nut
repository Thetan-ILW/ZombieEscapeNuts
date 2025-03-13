local GraphicalNote = require("mania/graphic_engine/graphical_note")

class GraphicalLaserNote extends GraphicalNote {
    function getFullColor() {
        switch(this.note.type) {
            case LaserType.Large:
                return [1, 1, 0.5, 1]
            case LaserType.Small:
                return [0.5, 1, 1, 1]
            case LaserType.SmallBlade:
                return [0.56, 0.5, 1, 1]
            case LaserType.LargeBlade:
                return [1, 0.5, 1, 1]
            default:
                return [1, 1, 1, 1]
        }
    }

    function update(absolute_delta_time, visual_delta_time, scaled_absolute_delta_time, scaled_visual_delta_time) {
        local x = this.note.position.x + this.position.x
        local y = this.note.position.y + this.position.y
        local z = scaled_visual_delta_time + this.position.z
        this.entity.SetAbsOrigin(Vector(x, y, z))

        local color = getFullColor()
        local a = absolute_delta_time * absolute_delta_time
        color[3] = math.max(0.2, 1 - a)
        world.setEntityColor(this.entity, color)
    }

    function spawn() {
        base.spawn()
        this.entity.SetAbsAngles(QAngle(0, this.note.angle, 0))
    }
}

module <- GraphicalLaserNote