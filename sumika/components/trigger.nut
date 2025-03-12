local EntityContainer = require("sumika/entity_container")

class Trigger extends EntityContainer {
    trigger = null
    touchedTimes = 0
    onTouch = null
    lines = null

    // Params
    position = null
    size = null
    once = false
    showBorders = false

    function load() {
        local trigger = SpawnEntityFromTable("trigger_multiple", {
            origin = this.position,
            spawnflags = 1,
        })
        local size = this.size
        trigger.SetSize(Vector(-size.x / 2, -size.y / 2, -size.z / 2), Vector(size.x / 2, size.y / 2, size.z / 2))
        trigger.SetSolid(2)
        trigger.ValidateScriptScope()

        local trigger_scope = trigger.GetScriptScope()
        trigger_scope.script <- this
        trigger_scope.touched <- function() {
            this.script.onStartTouch(activator)
        }
        trigger.ConnectOutput("OnStartTouch", "touched")

        this.trigger = this.addEntity("trigger", trigger)

        if (this.showBorders) {
            this.lines = []
            this.addLines(this.position, size)
        }
    }

    function addLines(origin, trigger_size) {
        local x = trigger_size.x / 2 - 4
        local y = trigger_size.y / 2 - 4
        local z = -trigger_size.z / 2 + 4

        local positions = [
            Vector(-x, -y, z),
            Vector(-x, y, z),
            Vector(x, y, z),
            Vector(x, -y, z),
        ]

        local params = {
            targetname = null,
            origin = null,
            renderamt = 255,
            rendercolor = "255 217 63",
            life = "0.06",
            BoltWidth = 2,
            NoiseAmplitude = 0,
            texture = "vgui/white_additive.vmt",
            TextureScroll = 0,
            damage = "0",
            LightningStart = null,
            LightningEnd = null,
            spawnflags = 1
        }

        local name_format = "line%i_" + Time().tostring()
        foreach(i, position in positions) {
            local name = format(name_format, i)
            params.targetname = name
            params.origin = origin + position
            params.LightningStart = name
            params.LightningEnd = format(name_format, (i + 1) % positions.len())
            local entity = this.addEntity(name, SpawnEntityFromTable("env_beam", params))
            this.lines.append(entity)
        }
    }

    function setLineColor(norm_color) {
        foreach (entity in this.lines) {
            world.setEntityColor(entity, norm_color)
        }
    }

    function onStartTouch(player) {
        if (!player)
            return

        if (this.once && this.touchedTimes > 0)
            return

        this.touchedTimes += 1

        if (typeof(this.onTouch) == "array") {
            local instance = this.onTouch[0]
            local func_name = this.onTouch[1]
            instance[func_name](this, player)
        }
        else {
            this.onTouch(this, player)
        }
    }

    function enable(player = null) {
        this.trigger.AcceptInput("Enable", "", player, null)
    }

    function disable(player = null) {
        this.trigger.AcceptInput("Disable", "", player, null)
    }

    function receive(event) {
        if (event.name == GameEvent.EntityLimitReached) {
            if (this.lines) {
                foreach(entity in this.lines) {
                    entity.Kill()
                }

                this.showBorders = false
                this.lines = null
            }
        }
    }
}

module <- Trigger