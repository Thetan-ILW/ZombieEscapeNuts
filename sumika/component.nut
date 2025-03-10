class Component {
    id = null
    stage = null
    killed = false

    constructor(params = null) {
        if (params) {
            foreach(key, value in params) {
                if (key in this) {
                    this[key] = value
                }
            }
        }

        this.killed = false
    }

    function load() {}
    function update() {}
    function entityLimitReached() {}
    function kill() {
        this.killed = true
    }
}

module <- Component