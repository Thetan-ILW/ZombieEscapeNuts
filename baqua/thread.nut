local thread = {
    constructor() {
        this.reset()
    }

    function reset() {
        this.coroutines <- {}
    }

    function update() {
        foreach(k, coro in this.coroutines) {
            if (coro.getstatus() == "suspended") {
                coro.wakeup()
            } else {
                delete this.coroutines[k]
            }
        }
    }

    function coro(f) {
        local coro = newthread(f)
        coro.call()
        this.coroutines[f] <- coro
    }

    function sleep(duration) {
        local end_time = Time() + duration
        while (Time() < end_time) {
            suspend()
        }
    }
}

module <- thread