class GraphicalNote {
    entity = null
    templateSpawner = null
    position = null

    note = null
    state = NoteState.Clear

    constructor(note, template_spawner, position) {
        this.note = note
        this.templateSpawner = template_spawner
        this.position = position
        this.state = NoteState.Clear
    }

    function spawn() {
        this.entity = this.templateSpawner.spawn()
        NetProps.SetPropBool(this.entity, "m_bForcePurgeFixedupStrings", true)
    }

    function kill() {
        this.entity.Kill()
    }

    function getAbsoluteTime() {
        return this.note.getAbsoluteTime()
    }

    function getAbsoluteEndTime() {
        return this.note.getAbsoluteEndTime()
    }

    function getVisualTime() {
        return this.note.getVisualTime()
    }

    function getVisualEndTime() {
        return this.note.getVisualEndTime()
    }
}

module <- GraphicalNote
