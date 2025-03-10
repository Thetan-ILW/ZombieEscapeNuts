local Note = require("nchart/note")

class LaserNote extends Note {
    position = null
    angle = 0
    type = LaserType.Large

    constructor(note_point, position, angle, type) {
        this.startNotePoint = note_point
        this.position = position
        this.angle = angle
        this.type = type
    }
}

module <- LaserNote