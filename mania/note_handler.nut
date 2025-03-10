class NoteHandler {
    notes = null
    column = 0

    currentNoteIndex = 0
    currentTime = 0

    __graphicEngine = null
    __scoringContainer = null

    windows = {
        miss = [-0.161, 0.1],
        hit = [-0.124, 0.1],
        nearest = false
    }

    constructor(notes, column, graphic_engine, scoring_container) {
        this.currentNoteIndex = 0
        this.notes = []
        this.column = column
        this.__graphicEngine = graphic_engine
        this.__scoringContainer = scoring_container

        foreach(i, note in notes) {
            if (note.column == column) {
                this.notes.append({
                    index = i,
                    time = note.getAbsoluteTime(),
                    state = NoteState.Clear,
                })
            }
        }
    }

    function setTime(time) {
        this.currentTime = time
    }

    function keyPressed() {
        if (this.currentNoteIndex >= notes.len()) {
            return
        }

        local note = this.notes[this.currentNoteIndex]
        local delta_time = this.currentTime - note.time
        local new_state = NoteState.Passed

        if (delta_time < this.windows.miss[0]) {
            new_state = NoteState.Clear
        }
        else if (delta_time < this.windows.hit[0]) {
            new_state = NoteState.Missed
        }
        else if (delta_time > this.windows.hit[1]) {
            new_state = NoteState.Missed
        }

        this.sendScoreEvent({
            note = note,
            noteIndex = note.index,
            oldState = note.state,
            newState = new_state,
            deltaTime = delta_time
        })

        note.state = new_state

        if (new_state != NoteState.Clear) {
            this.currentNoteIndex += 1
        }
    }

    function sendScoreEvent(event) {
        this.__graphicEngine.setNoteState(event.noteIndex, event.newState)
        this.__scoringContainer.event(event)
    }

    function update() {
        for (local i = this.currentNoteIndex; i < notes.len(); i++) {
            local note = this.notes[i]

            /*
            if (this.currentTime >= note.time) {
                this.sendScoreEvent({
                    note = note,
                    noteIndex = note.index,
                    oldState = note.state,
                    newState = NoteState.Passed,
                    deltaTime = this.currentTime - note.time
                })
                this.currentNoteIndex += 1
            }
                */

            if (this.currentTime > note.time + this.windows.miss[1] && note.state == NoteState.Clear) {
                this.sendScoreEvent({
                    note = note,
                    noteIndex = note.index,
                    newState = NoteState.Missed
                    deltaTime = 0
                })
                this.currentNoteIndex = i + 1
            }
            else {
                return
            }
        }
    }
}

module <- NoteHandler