local File = require("baqua/file")
local TemplateSpawner = require("baqua/template_spawner")
local Parkour = require("sumika/components/parkour")
local first_stage_parkours = require("sumika/stages/first_parkours")

local dev_parkour = Parkour()
dev_parkour.spawnImmediately()
local player = GetListenServerHost()

local dev = {
    function spawnShrine() {
        dev_parkour.devSpawnPart(ParkourPart.Shrine, player)
    }

    function spawnPlatform() {
        dev_parkour.devSpawnPart(ParkourPart.Platform, player)
    }

    function spawnWall() {
        dev_parkour.devSpawnPart(ParkourPart.Wall, player)
    }

    function deleteInView() {
        dev_parkour.devDeleteInView(player)
    }

    function saveToFile() {
        dev_parkour.devSaveToFile()
    }

    function addPos() {
        local pos = GetListenServerHost().GetOrigin()
        local str = File.read("positions")
        str += format("[%i, %i, %i],\n", math.round(pos.x, 16), math.round(pos.y, 16), pos.z)
        File.write("positions", str)
    }
}

module <- dev