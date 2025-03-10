local LaserNote = require("laserchart/graphic_engine/laser_note")

class GraphicalNoteFactory {
    templateSpawners = null
    spawnPosition = null

    constructor(template_spawners, spawn_position) {
        this.templateSpawners = template_spawners
        this.spawnPosition = spawn_position
    }

    function getNote(note) {
        return LaserNote(note, this.templateSpawners[note.type], this.spawnPosition)
    }
}

module <- GraphicalNoteFactory