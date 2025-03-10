local GraphicalNote = require("mania/graphic_engine/graphical_note")

class GraphicalLongNote extends GraphicalNote {
    function update(visual_delta_time) {
        local z = visual_delta_time * this.position.z + this.position.z
        this.entity.SetAbsOrigin(Vector(this.position.x, this.position.y, z))

        //NetProps.SetPropInt(this.entity, "m_clrRender", 0xff0000ff)
        switch (this.state) {
            case NoteState.Missed:
                NetProps.SetPropInt(this.entity, "m_clrRender", 0x33333333)
                break;
            case NoteState.Passed:
                this.entity.DisableDraw()
                break;
            default:
                break;
        }
    }
}

module <- GraphicalLongNote