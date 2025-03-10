local quest_complete_sound = "nier_automata/pickup_quest_complete.mp3"

class PickUpContainer {
    player = null
    pickUps = null
    frameAimTime = 1.0 / 66.0
    decayFactor = 0.97

    constructor(player_entity) {
        this.player = player_entity
        this.pickUps = []
        player.PrecacheSoundScript(quest_complete_sound)
    }

    function add(pick_up) {
        this.pickUps.append(pick_up)
    }

    function consumeFor(trigger) {
        local consumed = 0
        local remove_list = []

        for (local i = 0; i != this.pickUps.len(); i++) {
            local pick_up = this.pickUps[i]

            if (pick_up.targetTrigger != trigger)
                continue

            if (consumed == 0) {
                EmitSoundEx({
                    sound_name = quest_complete_sound,
                    entity = this.player,
                    filter_type = 4 // This player only
                })
            }

            pick_up.kill()
            consumed += 1
            remove_list.append(i)
        }

        for (local i = remove_list.len() - 1; i > -1; i--) {
            this.pickUps.remove(remove_list[i])
        }

        return consumed
    }

    function resetItems() {
        foreach (pick_up in this.pickUps) {
            pick_up.reset()
        }

        this.pickUps.clear()
    }

    function update() {
        if (!this.player.IsValid()) {
            this.resetItems()
            return
        }

        local target = this.player
        local player_angle = target.EyeAngles()
        local player_position = target.GetOrigin()

        local position_behind = player_position + RotatePosition(Vector(player_position.x, player_position.y, 0), player_angle, Vector(-56, 0, 0))
        local dest = position_behind + Vector(0, 0, 32)

        foreach (pick_up in this.pickUps) {
            local diff = dest - pick_up.getPosition()
            diff = diff * this.decayFactor
            local new_position = dest - diff
            pick_up.setPosition(new_position)
            dest = new_position + RotatePosition(Vector(new_position.x, new_position.y, 0), player_angle, Vector(-48, 0, 0))
        }
    }
}

module <- PickUpContainer