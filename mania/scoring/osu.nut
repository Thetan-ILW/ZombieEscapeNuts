local Scoring = require("mania/scoring/scoring")

class OsuScoring extends Scoring {
    windows = null
    hits = null

    notes = 0
    accuracy = 1.0
    lastCounter = null

    counters = [
        "perfect",
        "great",
        "good",
        "ok",
        "meh",
        "miss"
    ]

    weights = {
        perfect = 300.0,
        great = 300.0,
        good = 200.0,
        ok = 100.0,
        meh = 50.0,
        miss = 0.0,
    }

    constructor(od) {
        local od3 = 3.0 * od

        this.windows = {
            perfect = 16.0 / 1000.0,
            great = (64.0 - od3) / 1000.0,
            good = (97.0 - od3) / 1000.0,
            ok = (127.0 - od3) / 1000.0,
            meh = (151.0 - od3) / 1000.0,
            miss = (188.0 - od3) / 1000.0,
        }

        this.hits = {
            perfect = 0,
            great = 0,
            good = 0,
            ok = 0,
            meh = 0,
            miss = 0
        }

        this.notes = 0
        this.accuracy = 1.0
        this.lastCounter = null
    }

    function getCounter(delta_time) {
        delta_time = fabs(delta_time)

        foreach(key in this.counters) {
            local window = this.windows[key]

            if (delta_time < window) {
                return key
            }
        }

        return "miss"
    }

    function calculateAccuracy() {
        local max_score = this.notes * this.weights[this.counters[0]]
        local score = 0.0

        foreach(key, count in this.hits) {
            score = score + (this.weights[key] * count)
        }

        if (max_score > 0) {
            this.accuracy = math.max(0, score / max_score)
        }
        else {
            this.accuracy = 1.0
        }
    }

    function event(score_event) {
        if (score_event.newState == NoteState.Clear) {
            return
        }

        this.notes += 1

        if (score_event.newState == NoteState.Missed) {
            this.hits["miss"] += 1
            this.lastCounter = "miss"
            this.calculateAccuracy()
            return
        }

        local counter = this.getCounter(score_event.deltaTime)
        this.hits[counter] += 1
        this.lastCounter = counter
        this.calculateAccuracy()
    }
}

module <- OsuScoring