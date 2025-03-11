local PickUp = require("sumika/components/pick_up")
local Trigger = require("sumika/components/trigger")

local components = {
    function Key(position, trigger_name) {
        return PickUp({
            spritePath = "sumika/sprites/pick_up_key.vmt",
            initialPosition = position,
            initialColor = [1, 0.98, 0.21, 1],
            targetTrigger = trigger_name
        })
    }

    function Weed(position) {
        return PickUp({
            spritePath = "sumika/sprites/pick_up_weed.vmt",
            position = position + Vector(0, 0, 48),
            color = [0.66, 0.38, 1, 1],
            pickUpSound = "sumika/smoke_weed_everyday.mp3",
            onPickUp = function(pick_up, player) {
                EmitSoundEx({
                    sound_name = "sumika/smoke_weed_everyday.mp3",
                    entity = player,
                    filter_type = 4
                })
            }
        })
    }

    function BlueArchive(position) {
        return PickUp({
            spritePath = "sumika/sprites/pick_up_blue_archive.vmt",
            position = position + Vector(0, 0, 48),
            color = [1, 0, 0, 1],
            onPickUp = function(pick_up, player) {
                EmitSoundEx({
                    sound_name = "sumika/explosion.wav",
                    origin = player.GetOrigin()
                })

                player.TakeDamage(999999, 1, null)
            }
        })
    }

    function Trigger(position, size, on_success) {
        return Trigger({
            position = position,
            size = size,
            showBorders = true,
            onTouch = function(trigger, player_entity) {
                trigger.setLineColor([0.37, 1, 0.25, 1])
                trigger.disable()
                on_success(trigger, player_entity)
            }
        })
    }

    function KeyTrigger(position, size, trigger_name, keys_to_open, on_success) {
        return Trigger({
            position = position,
            size = size,
            showBorders = true,
            onTouch = function(trigger, player_entity) {
                local player_handler = this.stage.getPlayerHandler(player_entity)
                local consumed = player_handler.consumePickUps(trigger_name)

                if (consumed == 0) {
                    return
                }

                keys_to_open -= consumed

                if (keys_to_open == 1) {
                    Say(null, "Find a last key for this door!", false)
                    return
                }
                else if (keys_to_open > 1) {
                    Say(null, format("You need to bring here %i more keys!", keys_to_open), false)
                    return
                }

                trigger.setLineColor([0.37, 1, 0.25, 1])
                trigger.disable()
                on_success(trigger, player_entity)
            }
        })
    }
}

/*
function breakDoor(name) {
    local entity = Entities.FindByName(null, name)
    if (!entity)
        return
    entity.AcceptInput("Break", "", null, null)
}
    */

module <- components
