local Component = require("sumika/component")

local door_opened_sound = "nier_automata/door_open.mp3"

local Stage = class extends Component {
    events = null
    currentEventIndex = 0

    // Params
    playerHandlers = null
    entityPrefix = null

    constructor(params) {
        base.constructor(params)
        this.events = []
        this.currentEventIndex = 0
    }

    function load() {}

    function addEvent(delay, on_complete) {
        events.append({
            time = Time() + delay,
            onComplete = on_complete,
        })

        events.sort(function(a, b) {
            if (a.time > b.time)
                return 1
            else if (a.time < b.time)
                return -1
            return 0
        })
    }

    function getPlayerHandler(player_entity) {
        return this.playerHandlers[player_entity]
    }

    function getStage() {
        return this
    }

    function update() {
        for (local i = this.currentEventIndex; i < this.events.len(); i++) {
            local event = this.events[i]

            if (Time() < event.time)
                break

            event.onComplete()
            this.currentEventIndex = i + 1
        }
    }
}

module <- Stage