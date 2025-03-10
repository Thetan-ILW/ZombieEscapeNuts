local Chart = require("nchart/chart")
local Layers = require("nchart/layers")
local Note = require("nchart/note")

class ChartImporter {
    noteFactory = null

    constructor(note_factory) {
        assert(note_factory && "getNote" in note_factory)
        this.noteFactory = note_factory
    }

    function import(chart_table) {
        local layers = Layers(chart_table.timingPoints)
        local notes = this.getNotes(chart_table.notes, layers)

        // TODO: Add SoundNote with music to notes
        local chart = Chart(layers, notes)
        chart.columns = chart_table.columns
        return chart
    }

    function getNotes(raw_notes, layers) {
        local absolute = layers.absolute
        local visual = layers.visual

        local absolute_point = absolute[0]
        local visual_point = null
        local current_point_index = 0

        // We need to find a last point on a time point of the first absolute point
        foreach(i, p in absolute) {
            if (p.absoluteTime != absolute_point.absoluteTime) {
                break
            }
            current_point_index = i
            absolute_point = p
            visual_point = visual[i]
        }

        local notes = []

        foreach (raw_note in raw_notes) {
            local time = raw_note[0]
            local end_time = raw_note[1]
            local column = raw_note[2]

            // TODO: Find points for end_time
            if (current_point_index + 1 < absolute.len()) {
                local next_point = absolute[current_point_index + 1]

                while (time >= next_point.absoluteTime) {
                    current_point_index = current_point_index + 1

                    if (current_point_index + 1 < absolute.len()) {
                        next_point = absolute[current_point_index + 1]
                    }
                    else {
                        break
                    }
                }

                absolute_point = absolute[current_point_index]
                visual_point = visual[current_point_index]
            }

            this.noteFactory.setPoints(absolute_point, visual_point)

            local note = this.noteFactory.getNote(time, end_time, column)

            if (note) {
                if (typeof(note) == "array") {
                    foreach (n in note) {
                        notes.append(n)
                    }
                }
                else {
                    notes.append(note)
                }
            }
        }

        return notes
    }
}

module <- ChartImporter