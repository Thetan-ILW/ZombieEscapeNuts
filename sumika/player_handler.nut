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

    function getLastPickUp() {
        if (this.pickUps.len() != 0)
            return this.pickUps[this.pickUps.len() - 1]
    }

    function collectPickUp(pick_up) {
        this.pickUps.append(pick_up)
    }

    function consumePickUps(trigger_name) {
        foreach (pick_up in this.pickUps) {
            if (pick_up.targetTrigger == trigger_name) {
            }
        }
    }
}

module <- PlayerHandler