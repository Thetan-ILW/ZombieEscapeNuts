class Note {
    startNotePoint = null

    constructor(note_point) {
        this.startNotePoint = note_point
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
}

module <- Note