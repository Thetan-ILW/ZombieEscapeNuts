local EntityContainer = require("sumika/entity_container")
local Trigger = require("sumika/components/trigger")

local pick_up_sound = "nier_automata/pickup.mp3"
local orb_sprite_path = "sumika/sprites/pick_up_orb.vmt"

class PickUp extends EntityContainer {
    pickedUp = false
    initialPosition = null
    initialColor = null
    currentPosition = null

    orbEntity = null
    trigger = null
    onPickUp = null
    oneUse = false

    team = Team.Any

    targetTrigger = null

    constructor(params) {
        base.constructor(params)

        local sprite_path = params.spritePath
        local color = params.color
        local position = params.position
        this.initialPosition = position
        this.initialColor = color
        this.currentPosition = this.initialPosition + Vector()
        this.pickedUp = false

        local player = Entities.FindByClassname(null, "player")
        player.PrecacheModel(sprite_path)
        player.PrecacheModel(orb_sprite_path)
        player.PrecacheSoundScript(pick_up_sound)

        this.addEntity("icon", SpawnEntityFromTable("env_sprite", {
            targetname = "pickup",
            origin = position,
            model = sprite_path,
            spawnflags = 1,
            rendermode = 1,
            scale = 0.125,
        }))

        this.orbEntity = this.addEntity("orb", SpawnEntityFromTable("env_sprite", {
            targetname = "pickup_orb",
            origin = position,
            model = orb_sprite_path,
            spawnflags = 1,
            rendermode = 1,
            scale = 0.125,
        }))
        world.setEntityColor(this.orbEntity, color)

        local trigger = this.addEntity("trigger", SpawnEntityFromTable("trigger_multiple", {
            origin = params.position,
            spawnflags = 1
        }))
        trigger.SetSize(Vector(-20, -20, -20), Vector(20, 20, 20))
        trigger.SetSolid(2)
        trigger.ValidateScriptScope()

        local trigger_scope = trigger.GetScriptScope()
        trigger_scope.script <- this
        trigger_scope.touched <- function() {
            this.script.pickUp(activator)
        }
        trigger.ConnectOutput("OnStartTouch", "touched")
    }

    function pickUp(player) {
        if (this.pickedUp)
            return

        if (!player)
            return

        local scope = player.GetScriptScope()

        if (!("pickUpContainer") in scope)
            return

        EmitSoundEx({
            sound_name = pick_up_sound,
            entity = player,
            filter_type = 4 // This player only
        })

        world.setEntityColor(this.orbEntity, [1, 1, 1, 1])
        scope.pickUpContainer.add(this)
        this.pickedUp = true

        if (this.onPickUp)
            this.onPickUp(this, player)
    }

    function reset() {
        this.pickedUp = false

        foreach (entity in this.entities) {
            entity.SetAbsOrigin(this.initialPosition)
            this.currentPosition = this.initialPosition + Vector()
        }

        if (this.orbEntity) {
            world.setEntityColor(this.orbEntity, this.initialColor)
        }
    }

    function update() {
        local z = (sin(Time() * 2)) * 10
        local r = (Time() * 360) * 0.4
        local pos = this.currentPosition + Vector(0, 0, z)

        foreach (entity in this.entities) {
            entity.SetAbsOrigin(pos)
            entity.SetAbsAngles(QAngle(0, -r, 0))
        }
    }

    function getPosition() {
        return this.currentPosition
    }

    function setPosition(position) {
        this.currentPosition = position
        foreach (entity in this.entities) {
            entity.SetAbsOrigin(position)
        }
    }

    function entityLimitReached() {
        this.orbEntity.Kill()
        delete this.entities["orb"]
    }
}

module <- PickUp
