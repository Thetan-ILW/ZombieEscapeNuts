local NoteFactory = require("nchart/note_factory")
local NotePoint = require("nchart/note_point")
local ShortNote = require("mania/nchart/short_note")
local LongNote = require("mania/nchart/long_note")

class ManiaNoteFactory extends NoteFactory {
    function getNote(time, end_time, column) {
        local start_note_point = NotePoint(time, this.absolutePoint, this.visualPoint)

        if (end_time) {
            local end_note_point = NotePoint(end_time, this.absolutePoint, this.visualPoint)
            return LongNote(start_note_point, end_note_point, column)
        }

        return ShortNote(start_note_point, column)
    }
}

module <- ManiaNoteFactory