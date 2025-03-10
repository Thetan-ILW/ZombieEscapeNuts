IncludeScript("baqua/baqua", null)
require("sumika/enums")

local PickUpContainer = require("sumika/pick_up_container")
local FirstStage = require("sumika/stages/first")
local Parkour = require("sumika/components/parkour")

local player_scopes = {}

local function initPlayer(player) {
    local scope = player.GetScriptScope()

    player.ValidateScriptScope()
    scope = player.GetScriptScope()

    scope.pickUpContainer <- PickUpContainer(player)
    scope.update <- function() {
        this.pickUpContainer.update()
    }

    player_scopes[player] <- scope
}

local stage = FirstStage()
stage.load()

local crashed = false

function update() {
    if (crashed)
        return

    foreach(player, scope in player_scopes) {
        scope.update()
    }
    stage.update()
    return -1
}

seterrorhandler(function(e) {
    local Chat = @(m) (printl(m), ClientPrint(null, 2, m))
    Say(null, "LOL VSCRIPT ERROR", false)
    Say(null, "LOL VSCRIPT ERROR", false)
    Say(null, "LOL VSCRIPT ERROR", false)

    crashed = true

    Chat(format("\n====== TIMESTAMP: %g ======\nAN ERROR HAS OCCURRED [%s]", Time(), e))
    Chat("CALLSTACK")
    local s, l = 2
    while (s = getstackinfos(l++))
        Chat(format("*FUNCTION [%s()] %s line [%d]", s.func, s.src, s.line))
    Chat("LOCALS")
    if (s = getstackinfos(2))
    {
        foreach (n, v in s.locals)
        {
            local t = type(v)
            t ==    "null" ? Chat(format("[%s] NULL"  , n))    :
            t == "integer" ? Chat(format("[%s] %d"    , n, v)) :
            t ==   "float" ? Chat(format("[%s] %.14g" , n, v)) :
            t ==  "string" ? Chat(format("[%s] \"%s\"", n, v)) :
                             Chat(format("[%s] %s %s" , n, t, v.tostring()))
        }
    }
})

local function collectEventsInScope(events)
{
	local events_id = UniqueString()
	getroottable()[events_id] <- events
	local events_table = getroottable()[events_id]
	local Instance = self
	foreach (name, callback in events)
	{
		local callback_binded = callback.bindenv(this)
		events_table[name] = @(params) Instance.IsValid() ? callback_binded(params) : delete getroottable()[events_id]
	}
	__CollectGameEventCallbacks(events_table)
}

local events = {
    OnGameEvent_round_start = function(event) {
        // This is called after player_spawn event
        // Meaning you call initPlayers twice at the start of the round

        local camera = SpawnEntityFromTable("point_viewcontrol", {})

        for (local i = 1; i <= MaxClients(); i++) {
            local player = PlayerInstanceFromIndex(i)
            if (!player)
                continue
            initPlayer(player)
            camera.AcceptInput("Enable", "", player, player)
            camera.AcceptInput("Disable", "", player, player)
        }
        camera.Kill()
    },
    OnGameEvent_player_spawn = function(event) {
        local player = GetPlayerFromUserID(event.userid)
        if (!player)
            return

        initPlayer(player)
    },
    OnGameEvent_player_death = function(event) {
        local player = GetPlayerFromUserID(event.userid)
        if (!player || !(player in player_scopes))
            return

        local scope = player_scopes[player]
        scope.pickUpContainer.resetItems()
    }
}

collectEventsInScope(events)

AddThinkToEnt(self, "update")

///////////////////////// DEV STUFF //////////////////////////////////////
local File = require("baqua/file")
local TemplateSpawner = require("baqua/template_spawner")
local first_stage_parkours = require("sumika/stages/first_parkours")

local dev_parkour = Parkour()
dev_parkour.spawnImmediately()
local player = GetListenServerHost()

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

