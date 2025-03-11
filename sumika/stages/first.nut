local Stage = require("sumika/stage")
local Random = require("baqua/random")
local TemplateSpawner = require("baqua/template_spawner")

local PickUp = require("sumika/components/pick_up")
local Trigger = require("sumika/components/trigger")
local Parkour = require("sumika/components/parkour")
local MinigameButton = require("sumika/components/minigame_button")
local Nines = require("sumika/minigames/nines/init")

local parkours = require("sumika/stages/first_parkours")
local nines_arenas = require("sumika/stages/first_nines")

local random_blue_archives = [
    [-1024, -2448, 0],
    [-1024, -1840, 0],
    [-512, -1248, -95],
    [-1552, -1232, -95],
    [-1056, -752, 64],
    [-1536, -16, 64],
    [-1248, -352, 64],
    [-512, 16, 64],
    [-704, 96, 64],
    [-1584, 608, 32],
    [-1648, 1152, 16],
    [-16, 3904, 64],
    [1024, 4128, 64],
    [2000, 3968, 64],
    [-352, 1296, 64],
    [-640, 2608, 64],
    [-1616, -656, 126],
]

class FirstStage extends Stage {
    rng = null

    function start() {
        local stage = this
        local parkours = parkours.rightEntrance
        local parkour_index = ((rng.next() * 5000) % parkours.len()).tointeger()
        local parkour_params = parkours[parkour_index]

        local right_parkour = addComponent("rightSideParkour", Parkour(parkour_params))
        addCoroutine(function () {
            right_parkour.spawnAnimatedAsync()
        })
        local shrine_positions = right_parkour.getShrinePositions()

        local right_door = addComponent("rightEntranceTrigger", MultiKeyTrigger(
            Vector(-448, 272, 128),
            Vector(624, 416, 128),
            shrine_positions.len(),
            function(trigger, player) {
                stage.addEvent(5, function() {
                        right_parkour.kill()
                    }
                )
                stage.addEvent(20, function() {
                        trigger.kill()
                        breakDoor("s1_entrance_door")
                        stage.doorOpenedEffect()
                    }
                )

                Say(null, "The entrance will open in 20 seconds", false)
            }
        ))

        foreach(i, position in shrine_positions) {
            addComponent(format("rightEntranceKey%i", i), Key(position + Vector(0, 0, -88), right_door))
        }

        for (local i = 0; i < 5; i++) {
            local r = rng.next() * 1000
            local p = random_blue_archives[r % random_blue_archives.len()]
            local v = Vector(p[0], p[1], p[2])
            addComponent(format("entranceBlueArchive%i", i), BlueArchive(v))
        }

        local nines = addComponent("leftNines", Nines({
            arena = nines_arenas.leftEntrance,
            onComplete = function() {
                stage.addEvent(5, function() {
                        breakDoor("s1_entrance_left_door")
                        stage.doorOpenedEffect()
                    }
                )

                Say(null, "The left entrance will open in 5 seconds", false)
            }
        }))
        addComponent("leftButton", MinigameButton({
            position = Vector(-1120, -384, 64),
            angles = QAngle(0, 270, 0),
            minigame = nines
        }))
    }

    function load() {
        local stage = this
        local player = Entities.FindByClassname(null, "player")

        if (!player)
            return

        rng = Random(RandomInt(0, 1000) + Time())
        player.PrecacheSoundScript("sumika/smoke_weed_everyday.mp3")
        player.PrecacheSoundScript("sumika/explosion.wav")

        start()
    }
}

module <- FirstStage