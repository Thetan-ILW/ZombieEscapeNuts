local Character = class {
    entity = null
    sizeMin = Vector()
    sizeMax = Vector()

    isDead = false
    hits = 0
    maxHits = 10

    function moveTo(end_position) {
        local trace = {
            start = this.entity.GetOrigin(),
            end = end_position,
            hullmin = this.sizeMin,
            hullmax = this.sizeMax,
            ignore = this.entity,
            mask = -1
        }

        TraceHull(trace)
        this.entity.SetAbsOrigin(trace.endpos)

        // TODO: Try to slide when touching the walls
    }

    function update() {}

    function takeHit() {
        this.hits += 1
        this.isDead = this.hits >= this.maxHits
    }

    function kill() {
        entity.Kill()
    }
}

module <- Character