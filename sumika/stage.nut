local door_opened_sound = "nier_automata/door_open.mp3"

class Stage {
    playerHandlers = null
    components = null
    events = null
    coroutines = null
    currentEventIndex = 0

    constructor(player_handlers) {
        this.playerHandlers = player_handlers
        this.components = {}
        this.events = []
        this.coroutines = []
        this.currentEventIndex = 0
    }

    function load() {}

    function addComponent(id, component) {
        if (id in this.components)
            printl(format("Replacing stage component %s. Don't do that.", id))

        this.components[id] <- component
        component.id = id
        component.stage = this
        component.load()
        return component
    }

    function addEvent(delay, on_complete) {
        // TODO: Remove handled events
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

    // DEPRECATED
    function addCoroutine(f) {
        local coro = newthread(f)
        coro.call()
        this.coroutines.append(coro)
    }

    function getPlayerHandler(player_entity) {
        return this.players[player_entity]
    }

    function update() {
        foreach(i, coro in this.coroutines) {
            if (coro.getstatus() == "suspended") {
                coro.wakeup()
            }
            // Too lazy to remove dead coros xd
        }

        for (local i = this.currentEventIndex; i < this.events.len(); i++) {
            local event = this.events[i]

            if (Time() < event.time)
                break

            event.onComplete()
            this.currentEventIndex = i + 1
        }

        foreach(key, component in this.components) {
            if (component.killed) {
                this.components.rawdelete(key)
                continue
            }

            component.update()
        }
    }

    function receive(event) {
        foreach(component in this.components) {
            component.receive(event)
        }
    }

    // DEPRECATED
    function doorOpenedEffect() {
        local player = Entities.FindByClassname(null, "player")
        player.PrecacheSoundScript(door_opened_sound)
        EmitSoundEx({
            sound_name = door_opened_sound,
            filter_type = 5
        })
        ScreenFade(null, 96, 255, 63, 80, 0.7, 0, 1)
    }
}

module <- Stage