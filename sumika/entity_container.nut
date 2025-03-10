local Component = require("sumika/component")

class EntityContainer extends Component {
    entities = null

    constructor(params = null) {
        base.constructor(params)
        entities = {}
    }

    function addEntity(id, entity) {
        this.entities[id] <- entity
        return entity
    }

    function kill() {
        foreach(key, entity in this.entities) {
            entity.Kill()
            this.entities[key] = null
        }
        this.killed = true
    }
}

module <- EntityContainer