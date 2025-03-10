local NoteFactory = require("nchart/note_factory")
local NotePoint = require("nchart/note_point")
local LaserNote = require("laserchart/nchart/laser_note")
local Random = require("baqua/random")

class LaserNoteFactory extends NoteFactory {
    accumulatedNotes = 0
    previousTime = -math.huge
    random = null
    multiply = 1
    additionalAccumulatedNotes = 0

    constructor() {
        this.accumulatedNotes = 0
        this.additionalAccumulatedNotes = 0
        this.multiply = 1
        this.previousTime = -math.huge
        this.random = Random(69133769)
    }

    function getLaserType() {
        switch (this.accumulatedNotes) {
            case 1:
                return LaserType.Large
            case 2:
                return LaserType.Small
            case 3:
                return LaserType.SmallBlade
            case 4:
                return LaserType.LargeBlade
            case 5:
                return LaserType.Cross
            default:
                return LaserType.Cross
        }
    }

    function randomPoint() {
        local t = 2 * PI * this.random.next()
        local u = RandomFloat(0, 1) + this.random.next()
        local r = u
        if (u > 1) {
            r = 2 - u;
        }
        return Vector2D(
            (r * cos(t)),
            (r * sin(t))
        )
    }

    function getNote(time, end_time, column) {
        if (time != this.previousTime) {
            this.accumulatedNotes += this.additionalAccumulatedNotes
            local type = getLaserType()
            local multiply = this.multiply

            if (type == LaserType.Cross || type == LaserType.Small) {
                multiply += 1
            }

            local notes = []

            for (local i = 0; i != multiply; i++) {
                notes.append(LaserNote(
                    NotePoint(time, this.absolutePoint, this.visualPoint),
                    randomPoint(),
                    this.random.next() * 360,
                    type
                ))
            }

            this.accumulatedNotes = 0
            this.previousTime = time
            return notes
        }

        this.accumulatedNotes += 1
    }
}

module <- LaserNoteFactory