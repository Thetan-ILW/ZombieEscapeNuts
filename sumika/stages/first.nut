local SumikaStage = require("sumika/stages/sumika_stage")
local Component = require("sumika/component")
local Random = require("baqua/random")

local LaserChart = require("sumika/components/laser_chart")
local MinigameButton = require("sumika/components/minigame_button")
local Nines = require("sumika/minigames/nines/init")
local Parkour = require("sumika/components/parkour")
local parkours = require("sumika/stages/first_parkours")
local blue_archives = require("sumika/stages/first_blue_archives")
local nines_arenas = require("sumika/stages/first_nines")
local Key = SumikaStage.Key

local First = class extends SumikaStage {
    rng = null

    function entrance() {
        local _this = this

        local e = addChild("entrance", Component())

        local key_count = addParkourWithKeys(e, this.rng.nextElement(parkours.rightEntrance), "door")

        local left_door_triggered = false
        local right_door_triggered = false

        local function openDoors() {
            _this.say("Both ways will open in 20 seconds!")
            _this.say("Get ready for a split defense, both sides would have to hack the terminals.")
            _this.addEvent(20, function() {
                _this.breakDoor("s1_entrance_door")
                _this.breakDoor("s1_entrance_left_door")
                _this.doorOpenedEffect()
            })

            _this.addEvent(21, function() {
                _this.say("Can someone hack the terminal on the right? Please?")
                e.killTree()
            })

            _this.addEvent(22, function() {
                _this.infiltration()
            })

            _this.addEvent(25, function() {
                _this.breakDoor("s1_entrance_zm_fence")
                _this.say("*Whispher* Zombies, you can jump down to the catwalk and kill silly humans muahahaha!")
            })
        }

        e.addChild("trigger", KeyTrigger(
            Vector(-448, 272, 128),
            Vector(624, 416, 128),
            "door",
            key_count,
            function(trigger, player) {
                right_door_triggered = true
                if (right_door_triggered && left_door_triggered)
                    openDoors()
                else
                    _this.say("The right door will open after the left terminal is hacked.")
            }
        ))

        local nines = e.addChild("ninesLeft", Nines({
            arena = this.rng.nextElement(nines_arenas),
            onComplete = function(player) {
                local player_handler = _this.getPlayerHandler(player)
                Say(null, format("%s hacked the left door, nice!", player_handler.getUsername()), false)
                left_door_triggered = true

                if (right_door_triggered && left_door_triggered)
                    openDoors()
                else
                    _this.say("The left door will open after you collect all keys for the right door.")
            }
        }))

        e.addChild("ninesButtonLeft", MinigameButton({
            position = Vector(-1952, -36, 64),
            angles = QAngle(0, 270, 0),
            minigame = nines
        }))

        /*
        e.addChild("laserChart", LaserChart({
            hitPosition = Vector(10240, 2048, 283),
            noteChartPath = "charts/4243e617f722204d6f8a160647c5fe5e_1",
            playerHandlers = this.playerHandlers,
            onComplete = function() {

            }
        }))
            */
    }

    function infiltration() {
        local e = addChild("infiltration", Component())
        local key_count = addParkourWithKeys(e, this.rng.nextElement(parkours.leftInfiltration), "leftStairs")
    }

    function load() {
        this.rng = Random()

        local outside = addChild("outside", Component())
        for (local i = 0; i < 5; i++) {
            local params = this.rng.nextElement(blue_archives.entrance)
            outside.addChild(format("blueArchive%i", i), BlueArchive(Vector(params[0], params[1], params[2])))
        }

        this.entrance()
    }
}

module <- First