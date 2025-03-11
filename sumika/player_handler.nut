local PickUpContainer = require("sumika/pick_up_container")

class PlayerHandler {
    entity = null
    pickUps = null

    constructor(entity) {
        this.entity = entity
        this.pickUps = []
    }

    function onRespawn() {
        this.pickUps = []
    }

    function collectPickUp() {

    }

    function consumePickUps(key, type) {

    }
}

module <- PlayerHandler