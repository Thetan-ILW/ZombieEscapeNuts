local LayerPoint = require("nchart/layer_point")
local getPrimaryTempo = require("nchart/primary_tempo")

// Raw timing point:
// [0]: Absolute Time
// [1]: Tempo?
// [2]: Velocity?

local TimingPoint = class {
    absoluteTime = 0
    tempo = null
    velocity = null

    constructor(absolute_time, tempo, velocity) {
        this.absoluteTime = absolute_time
        this.tempo = tempo
        this.velocity = velocity
    }
}

class Layers {
    primaryTempo = 120.0
    absolute = null
    visual = null

    constructor(raw_timing_points) {
        assert(raw_timing_points)
        this.absolute = null
        this.visual = null

        local sorted = this.getTimingPoints(raw_timing_points)
        this.primaryTempo = getPrimaryTempo(sorted)
        assert(this.primaryTempo > 0)

        this.createAbsolutePoints(sorted)
        this.createVisualPoints(this.absolute)
        assert(this.absolute.len() == this.visual.len())
    }

    function printRange(a, b) {
        local a = math.max(0, a)
        local b = math.min(b, this.absolute.len())

        printl("--- ABSOLUTE ---")
        for (local i = a; i < b; i++) {
            local p = this.absolute[i]
            printf("Index: %i | Time: %g | Duration: %g | Speed: %g\n", i, p.absoluteTime, p.duration, p.currentSpeed)
        }

        printl("--- VISUAL ---")
        for (local i = a; i < b; i++) {
            local p = this.visual[i]
            printf("Index: %i | Time: %g | Duration: %g | Speed: %g\n", i, p.absoluteTime, p.duration, p.currentSpeed)
        }
    }

    function getTimingPoints(raw_array) {
        local points = []

        foreach (p in raw_array) {
            local time = p[0].tofloat()
            local tempo = null
            local velocity = null
            if (p[1])
                tempo = p[1].tofloat()
            if (p[2])
                velocity = p[2].tofloat()
            points.append(TimingPoint(time, tempo, velocity))
        }

        points.sort(function(a, b) {
            if (a.absoluteTime > b.absoluteTime)
                return 1
            if (a.absoluteTime < b.absoluteTime)
                return -1
            return 0
        })

        local current_time = points[0].absoluteTime
        local sorted = []
        local v = []

        for (local i = 0; i < points.len(); i++) {
            local p = points[i]

            if (p.absoluteTime != current_time) {
                foreach (vp in v) {
                    sorted.append(vp)
                }
                v = []
                current_time = p.absoluteTime
            }

            if (p.tempo) {
                sorted.append(p)
            }
            else {
                v.append(p)
            }
        }

        foreach(vp in v) {
            sorted.append(vp)
        }

        return sorted
    }

    function createAbsolutePoints(timing_points) {
        local points = []

        if (timing_points.len() == 1) {
            points.append(LayerPoint(timing_points[0].absoluteTime, 120*60, 1.0))
            this.absolute = points
            return
        }

        local current_tempo_point = null

        foreach(p in timing_points) {
            if (p.tempo) {
                current_tempo_point = p
                break
            }
        }

        timing_points.append(TimingPoint(120.0 * 60.0, null, 1.0))
        for (local i = 0; i != timing_points.len() - 1; i++) {
            local tp = timing_points[i]
            local ntp = timing_points[i + 1]

            if (tp.tempo) {
                current_tempo_point = tp
            }

            local speed = current_tempo_point.tempo / this.primaryTempo
            if (tp.velocity) {
                speed = speed * tp.velocity
            }

            points.append(LayerPoint(tp.absoluteTime, ntp.absoluteTime - tp.absoluteTime, speed))
        }

        this.absolute = points
    }

    function createVisualPoints(absolute) {
        local points = []
        local current_time = absolute[0].absoluteTime

        foreach(p in absolute) {
            local duration = p.duration * p.currentSpeed
            points.append(LayerPoint(current_time, duration, p.currentSpeed))
            current_time += duration
        }

        this.visual = points
    }
}

module <- Layers