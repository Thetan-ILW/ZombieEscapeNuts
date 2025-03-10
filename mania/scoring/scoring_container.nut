local BaseScoring = require("mania/scoring/base")
local OsuScoring = require("mania/scoring/osu")

// Rename to ScoreSystem, implement main score system, automatically apply timings from main score system
// Use table of oldState = { newState = function() , anotherNewState = function() } like in soundsphere. Tables can use enums
// Add LogicalShortNote and LogicalLongNote, pass it to score systems together with a tap event
class ScoringContainer {
    scorings = {
        _base = BaseScoring(),
        osu = OsuScoring(9)
    }

    function event(score_event) {
        foreach (scoring in this.scorings) {
            scoring.event(score_event)
        }
    }
}

module <- ScoringContainer