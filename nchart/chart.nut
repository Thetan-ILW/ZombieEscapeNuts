class Chart {
    minTime = 0
    maxTime = 0

    columns = 0
    notes = []
    layers = null

    constructor(layers, notes) {
        this.layers = layers

        this.minTime = notes[0].getAbsoluteTime()
        this.maxTime = notes[notes.len() - 1].getAbsoluteEndTime()
        this.notes = notes
    }
}

module <- Chart