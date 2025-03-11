local TestStage = require("sumika/stages/test")
local PlayerHandler = require("sumika/player_handler")

local main = {
    function load() {
        this.playerHandlers <- {}
        this.stage <- TestStage(this.playerHandlers)
        this.stage.load()
    }

    function update() {
        this.stage.update()
    }

    function addPlayerHandler(player_entity) {
        if (player_entity in this.playerHandlers) {
            this.playerHandlers[player_entity].onRespawn()
            return
        }

        this.playerHandlers[player_entity] <- PlayerHandler(player_entity)
    }

    function roundStarted() {
        local camera = SpawnEntityFromTable("point_viewcontrol", {})

        for (local i = 1; i <= MaxClients(); i++) {
            local player_entity = PlayerInstanceFromIndex(i)
            if (!player_entity)
                continue
            this.addPlayerHandler(player_entity)
            camera.AcceptInput("Enable", "", player_entity, player_entity)
            camera.AcceptInput("Disable", "", player_entity, player_entity)
        }

        camera.Kill()
    }

    function receive(event) {
        switch (event.name) {
            case GameEvent.PlayerSpawn:
                local player_entity = GetPlayerFromUserID(event.data.userid)
                this.addPlayerHandler(player_entity)
                break
            case GameEvent.RoundStart:
                this.roundStarted()
                break
            default:
                break
        }

        this.stage.receive(event)
    }
}

module <- main