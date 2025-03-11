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

    function removeEntity(id) {
        delete this.entities[id]
    }

    function killTree() {
        foreach(key, entity in this.entities) {
            entity.Kill()
        }

        base.killTree()
    }
}

module <- EntityContainer