module <- function(timing_points) {
    local min_tempo = math.huge
    local max_tempo = -math.huge

    local durations = {}
    local prev_time = timing_points[timing_points.len() - 1].absoluteTime

    for (local i = timing_points.len() - 1; i > -1; i--) {
        local p = timing_points[i]

        if (!p.tempo)
            continue

        min_tempo = math.min(min_tempo, p.tempo)
        max_tempo = math.max(max_tempo, p.tempo)

        if (!(p.tempo in durations)) {
            durations[p.tempo] <- 0
        }
        durations[p.tempo] += prev_time - p.absoluteTime

        prev_time = p.absoluteTime
    }

    local longest = -1
    local primary_tempo = 0
    foreach(tempo, duration in durations) {
        if (duration > longest) {
            longest = duration
            primary_tempo = tempo
        }
    }

    return primary_tempo
}