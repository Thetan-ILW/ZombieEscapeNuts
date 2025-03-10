local GraphicalNote = require("mania/graphic_engine/graphical_note")

local HARDCODED_VALUE = 300

class GraphicalLaserNote extends GraphicalNote {
    function getFullColor() {
        switch(this.note.type) {
            case LaserType.Large:
                return 0xff80fffb
            case LaserType.Small:
                return 0xffffe980
            case LaserType.SmallBlade:
                return 0xffff808f
            case LaserType.LargeBlade:
                return 0xfff580ff
            default:
                return 0xffffffff
        }
    }

    function update(absolute_delta_time, visual_delta_time) {
        local x = (this.note.position.x * HARDCODED_VALUE) + this.position.x
        local y = (this.note.position.y * HARDCODED_VALUE) + this.position.y
        local z = absolute_delta_time + this.position.z
        this.entity.SetAbsOrigin(Vector(x, y, z))

        if (absolute_delta_time <= 0) {
            NetProps.SetPropInt(this.entity, "m_clrRender", this.getFullColor())
        }
        else {
            NetProps.SetPropInt(this.entity, "m_clrRender", 0x44444444)
        }

    }

    function spawn() {
        base.spawn()
        this.entity.SetAbsAngles(QAngle(0, this.note.angle, 0))
    }
}

module <- GraphicalLaserNote