local ShortNote = require("mania/graphic_engine/short_note")
local LongNote = require("mania/graphic_engine/long_note")

class GraphicalNoteFactory {
    templateSpawners = null
    columnPositions = null

    constructor(template_spawners, column_positions) {
        this.templateSpawners = template_spawners
        this.columnPositions = column_positions
    }

    function getNote(note) {
        local graphical_note = null
        local spawner = null
        local g_note_class = null

        switch (typeof(note)) {
            case NoteType.ShortNote:
                spawner = this.templateSpawners[NoteType.ShortNote][note.column]
                g_note_class = ShortNote
                break;
            case NoteType.LongNote:
                spawner = this.templateSpawners[NoteType.LongNote][note.column]
                g_note_class = LongNote
                break;
            default:
                printf(format("[%s: %i] Unknown note type %i. Skipping.", __FILE__, __LINE__, type(note)))
                break;
        }

        return g_note_class(note, spawner, this.columnPositions[note.column])
    }
}

module <- GraphicalNoteFactory