local Scoring = require("mania/scoring/scoring")

class BaseScoring extends Scoring{
    notes = 0
    hits = 0
    miss = 0
    combo = 0
    maxCombo = 0

    totalDeltaTime = 0
    mean = 0

    constructor() {
        this.notes = 0
        this.hits = 0
        this.miss = 0
        this.combo = 0
        this.maxCombo = 0
        this.totalDeltaTime = 0
        this.mean = 0
    }

    function event(score_event) {
        local new_state = score_event.newState

        this.notes += 1

        if (new_state == NoteState.Missed) {
            this.miss += 1
            this.combo = 0
        }
        else if (new_state == NoteState.Passed) {
            this.hits += 1
            this.combo += 1
            this.maxCombo = math.max(this.maxCombo, this.combo)
        }

        this.totalDeltaTime += score_event.deltaTime

        if (this.hits != 0)
            this.mean = this.totalDeltaTime / this.hits
    }
}

module <- BaseScoring