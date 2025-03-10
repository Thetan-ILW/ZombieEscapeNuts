local ShortNote = require("mania/nchart/short_note")

class LongNote extends ShortNote {
    endNotePoint = null

    constructor(start_note_point, end_note_point, column) {
        this.startNotePoint = start_note_point
        this.endNotePoint = end_note_point
        this.column = column
    }

    function getAbsoluteEndTime() {
        return this.endNotePoint.absoluteTime
    }

    function getVisualEndTime() {
        return this.endNotePoint.visualEndTime
    }

    function _typeof() {
        return NoteType.LongNote
    }
}

module <- LongNote