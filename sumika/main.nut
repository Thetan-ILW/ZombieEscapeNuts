local TestStage = require("sumika/stages/test")
local Player = require("sumika/player")

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

        this.playerHandlers[player_entity] <- Player(player_entity)
    }

    function roundStarted() {
        local camera = SpawnEntityFromTable("point_viewcontrol", {})

        for (local i = 1; i <= MaxClients(); i++) {
            local player = PlayerInstanceFromIndex(i)
            if (!player)
                continue
            this.addPlayer(player)
            camera.AcceptInput("Enable", "", player, player)
            camera.AcceptInput("Disable", "", player, player)
        }

        camera.Kill()
    }

    function receive(event) {
        switch (event.name) {
            case GameEvent.PlayerSpawn:
                local player_entity = GetPlayerFromUserID(event.data.userid)
                this.addPlayerHandler(player_entity)
                break
            case GameEvent.RoundStarted:
                this.roundStarted()
                break
            default:
                break
        }

        this.stage.receive(event)
    }
}

module <- main