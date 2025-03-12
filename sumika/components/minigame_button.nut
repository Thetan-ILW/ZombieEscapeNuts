local EntityContainer = require("sumika/entity_container")

local MinigameButton = class extends EntityContainer {
    position = null
    angles = null
    minigame = null

    function load() {
        this.addEntity("prop", SpawnEntityFromTable("prop_dynamic", {
            model = "models/props_combine/combine_interface002.mdl",
            solid = 6,
            origin = position,
            angles = angles
        }))

        local button = this.addEntity("button", SpawnEntityFromTable("func_button", {
            origin = position,
            spawnflags = 1025
        }))
        button.SetSize(Vector(-10, -10, -10), Vector(10, 10, 10))
        button.ValidateScriptScope()

        local scope = button.GetScriptScope()
        local _this = this
        scope.pressed <- function () {
            _this.pressed(activator)
        }
        button.ConnectOutput("OnPressed", "pressed")
    }

    function pressed(player_entity) {
        if (!player_entity)
            return

        switch (this.minigame.status) {
            case MinigameStatus.Completed:
            case MinigameStatus.InProgress:
                return;
        }

        local minigame = this.minigame
        thread.coro(@() minigame.introSequenceAsync(player_entity))
    }
}

module <- MinigameButton