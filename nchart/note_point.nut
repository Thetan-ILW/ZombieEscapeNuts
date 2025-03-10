class Note {
    absoluteTime = null
    visualTime = null
    absolutePoint = null
    visualPoint = null

    constructor(absolute_time, absolute_point, visual_point) {
        this.absolutePoint = absolute_point
        this.visualPoint = visual_point
        this.absoluteTime = absolute_time
        this.visualTime = this.getVisualTime(absolute_time)
    }

    function getVisualTime(absolute_time) {
        local absolute_norm = (absolute_time - this.absolutePoint.absoluteTime) / this.absolutePoint.duration
        return this.visualPoint.absoluteTime + (this.visualPoint.duration * absolute_norm)
    }
}

module <- Note