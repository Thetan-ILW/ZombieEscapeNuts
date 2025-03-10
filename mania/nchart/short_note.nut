local Note = require("nchart/note")

class ShortNote extends Note {
    startNotePoint = null
    column = 0

    constructor(note_point, column) {
        this.startNotePoint = note_point
        this.column = column
    }

    function getAbsoluteTime() {
        return this.startNotePoint.absoluteTime
    }

    function getAbsoluteEndTime() {
        return this.startNotePoint.absoluteTime
    }

    function getVisualTime() {
        return this.startNotePoint.visualTime
    }

    function getVisualEndTime() {
        return this.startNotePoint.visualEndTime
    }

    function _typeof() {
        return NoteType.ShortNote
    }
}

module <- ShortNote