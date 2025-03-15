local GraphicalNoteFactory = require("mania/graphic_engine/note_factory")

class GraphicEngine {
    absoluteCurrentTime = -math.huge
    visualCurrentTime = -math.huge
    absolutePoint = null
    visualPoint = null

    scrollSpeed = 4.1
    minTime = 1.0
    maxTime = 1.0

    graphicalNoteFactory = null
    graphicalNotes = null
    currentNoteIndex = 0
    startDrawIndex = 0

    constructor(graphical_note_factory) {
        this.graphicalNoteFactory = graphical_note_factory
    }

    function setNotes(notes) {
        assert(notes && notes.len() > 0)
        this.currentNoteIndex = 0
        this.startDrawIndex = 0
        this.graphicalNotes = []

        foreach (note in notes) {
            this.graphicalNotes.append(this.graphicalNoteFactory.getNote(note))
        }
    }

    function setNoteState(index, state) {
        this.graphicalNotes[index].state = state
    }

    function setTime(absolute_time, visual_time) {
        this.absoluteCurrentTime = absolute_time
        this.visualCurrentTime = visual_time
    }

    function setPoints(absolute, visual) {
        this.absolutePoint = absolute
        this.visualPoint = visual
    }

    function update() {
        local current_time = this.absoluteCurrentTime

        local spawn_time = this.minTime
        local kill_time = this.maxTime

        for (local i = this.currentNoteIndex; i < this.graphicalNotes.len(); i++) {
            local note = this.graphicalNotes[i]

            if (current_time < note.getAbsoluteTime() - spawn_time)
                break

            if (this.currentNoteIndex - this.startDrawIndex > 300) {
                break
            }

            this.currentNoteIndex = i + 1
            note.spawn()
        }

        for (local i = this.startDrawIndex; i < this.currentNoteIndex; i++) {
            local note = this.graphicalNotes[i]

            if (this.visualCurrentTime > note.getVisualTime() + kill_time) {
                note.kill()
                this.startDrawIndex = i + 1
                continue
            }

            local dt = note.getVisualTime() - this.visualCurrentTime
            local adt = note.getAbsoluteTime() - this.absoluteCurrentTime
            note.update(adt, dt, adt * this.scrollSpeed, dt * this.scrollSpeed)
        }
    }
}

module <- GraphicEngine