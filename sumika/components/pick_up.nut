local EntityContainer = require("sumika/entity_container")

local pick_up_sound = "nier_automata/pickup.mp3"
local orb_sprite_path = "sumika/sprites/pick_up_orb.vmt"

local trace = {
    start = null,
    end = null,
    hullmin = Vector(-20, -20, -20),
    hullmax = Vector(20, 20, 20),
}

class PickUp extends EntityContainer {
    playerHandler = null
    followEntity = null
    currentPosition = null

    icon = null
    orbEntity = null

    // Params
    team = Team.Any
    targetTrigger = null
    initialPosition = null
    initialColor = [1, 1, 1, 1]
    spritePath = null
    onPickUp = null
    oneUse = false
    onZombiePickedHumanItem = null

    function load() {
        this.followEntity = null
        this.currentPosition = this.initialPosition + Vector()

        local player = Entities.FindByClassname(null, "player")
        player.PrecacheModel(this.spritePath)
        player.PrecacheModel(orb_sprite_path)
        player.PrecacheSoundScript(pick_up_sound)

        this.icon = this.addEntity("icon", SpawnEntityFromTable("env_sprite", {
            targetname = "pickup",
            origin = this.initialPosition,
            model = this.spritePath,
            spawnflags = 1,
            rendermode = 1,
            scale = 0.125,
        }))

        this.orbEntity = this.addEntity("orb", SpawnEntityFromTable("env_sprite", {
            targetname = "pickup_orb",
            origin = this.initialPosition,
            model = orb_sprite_path,
            spawnflags = 1,
            rendermode = 1,
            scale = 0.125,
        }))
        world.setEntityColor(this.orbEntity, this.initialColor)
    }

    function pickUp(player_entity) {
        if (this.followEntity)
            return

        if (!player_entity)
            return

        local player_team = player_entity.GetTeam()

        if (this.team == Team.Zombie && player_team == Team.Human)
            return

        if (this.team == Team.Human && player_team == Team.Zombie) {
            // Don't allow zombies to interact when human died and pick up is flying towards the initial position
            local distance = abs(this.icon.GetOrigin() - this.initialPosition)
            if (distance > 10) {
                return
            }

            if (this.onZombiePickedHumanItem)
                this.onZombiePickedHumanItem()
        }

        if (this.orbEntity)
            world.setEntityColor(this.orbEntity, [1, 1, 1, 1])

        EmitSoundEx({
            sound_name = pick_up_sound,
            entity = player_entity,
            filter_type = 4 // This player only
        })

        this.playerHandler = this.getStage().getPlayerHandler(player_entity)
        this.followEntity = this.playerHandler.getLastPickUp() || this.playerHandler
        this.playerHandler.collectPickUp(this)

        if (this.onPickUp)
            this.onPickUp(this, player_entity)
    }

    function reset() {
        this.followEntity = null

        if (this.orbEntity)
            world.setEntityColor(this.orbEntity, this.initialColor)
    }

    function update() {
        if (!this.followEntity) {
            trace.start = this.currentPosition
            trace.end = this.currentPosition
            TraceHull(trace)

            if (trace.hit && trace.enthit.IsPlayer()) {
                trace.hit = null
                this.pickUp(trace.enthit)
            }
        }

        local destination = this.initialPosition

        if (this.followEntity) {
            local player_angle = this.playerHandler.entity.EyeAngles()

            if (this.followEntity == this.playerHandler) {
                destination = this.playerHandler.entity.GetOrigin() + Vector(0, 0, 32)
            }
            else {
                destination = this.followEntity.getPosition()
            }

            player_angle.x *= 0.1
            destination = destination + RotatePosition(destination, player_angle, Vector(-56, 0, 0))
        }

        local diff = (destination - this.currentPosition) * 0.97
        this.currentPosition = destination - diff

        local visual_position = this.currentPosition + Vector(0, 0, sin(Time() * 2.5) * 8)
        local angle = QAngle(0, -Time() * 75, 0)

        foreach (entity in this.entities) {
            entity.SetAbsOrigin(visual_position)
            entity.SetAbsAngles(angle)
        }
    }

    function getPosition() {
        return this.currentPosition
    }

    function receive(event) {
        if (event.name == GameEvent.EntityLimitReached) {
            this.orbEntity.Kill()
            this.orbEntity = null
            this.removeEntity("orb")
        }
    }
}

module <- PickUp
