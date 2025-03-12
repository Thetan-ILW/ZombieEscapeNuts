local NoteFactory = require("nchart/note_factory")
local NotePoint = require("nchart/note_point")
local LaserNote = require("laserchart/nchart/laser_note")
local Random = require("baqua/random")

local LaserNativeNoteFactory = class extends NoteFactory {
    previousTime = -math.huge
    random = null

    constructor() {
        this.previousTime = -math.huge
        this.random = Random(69133769)
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
        local type = LaserType.Large

        switch (column) {
            case 0:
                type = LaserType.Large
                break
            case 1:
                type = LaserType.Small
                break
            case 2:
                type = LaserType.SmallBlade
                break
            case 3:
                type = LaserType.LargeBlade
                break
            case 4:
                type = LaserType.Cross
                break
            default:
                type = LaserType.Cross
                break
        }

        local multiply = 1

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

        this.previousTime = time
        return notes
    }
}

module <- LaserNativeNoteFactory