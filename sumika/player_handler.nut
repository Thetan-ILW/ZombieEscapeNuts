local quest_complete_sound = "nier_automata/pickup_quest_complete.mp3"

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

    function removePickUp(pick_up) {
        foreach(i, v in this.pickUps) {
            if (v == pick_up) {
                this.pickUps.remove(i)
                return
            }
        }
    }

    function consumePickUps(trigger_name) {
        local consumed = 0
        local remove_list = []

        foreach(i, pick_up in this.pickUps) {
            if (pick_up.targetTrigger == trigger_name) {
                consumed += 1
                remove_list.append(i)
            }
        }

        for (local i = remove_list.len() - 1; i > -1; i--) {
            local index = remove_list[i]
            this.pickUps[index].killTree()
            this.pickUps.remove(index)
        }

        if (consumed > 0) {
            this.entity.PrecacheScriptSound(quest_complete_sound)
            EmitSoundEx({
                sound_name = quest_complete_sound,
                entity = this.entity,
                filter_type = 4
            })
        }

        return consumed
    }

    function getUsername() {
        return NetProps.GetPropString(this.entity, "m_szNetname")
    }

    function getSteamId() {
        return NetProps.GetPropString(this.entity, "m_szNetworkIDString")
    }
}

module <- PlayerHandler