local SumikaStage = require("sumika/stages/sumika_stage")
local Random = require("baqua/random")

local Parkour = require("sumika/components/parkour")
local parkours = require("sumika/stages/first_parkours")
local blue_archives = require("sumika/stages/first_blue_archives")

local Key = SumikaStage.Key

local First = class extends SumikaStage {
    rng = null

    function entrance() {
        local _this = this

        for (local i = 0; i < 5; i++) {
            local params = this.rng.nextElement(blue_archives.entrance)
            addComponent(format("blueArchive%i", i), BlueArchive(Vector(params[0], params[1], params[2])))
        }

        local parkour = addComponent("parkour", Parkour({
            parkourPartParams = this.rng.nextElement(parkours.rightEntrance)
        }))

        local shrine_positions = parkour.getShrinePositions()

        addComponent("trigger", KeyTrigger(
            Vector(-448, 272, 128),
            Vector(624, 416, 128),
            "door",
            shrine_positions.len(),
            function(trigger, player) {
                Say(null, "The right door will open in 20 seconds!", false)
                Say(null, "Get ready for a split defense, both sides would have to hack the terminals.", false)

                _this.addEvent(20, function() {
                    _this.breakDoor("s1_entrance_door")
                    _this.doorOpenedEffect()
                })

                _this.addEvent(21, function() {
                    Say(null, "Can someone hack the terminal on the right? Please?", false)
                })
            }
        ))

        thread.coro(function () {
            parkour.spawnAnimatedAsync()
            foreach(i, position in shrine_positions) {
                _this.addComponent(format("key%i", i), Key(position + Vector(0, 0, -40), "door"))
            }
        })
    }

    function load() {
        this.rng = Random()
        this.entrance()
    }
}

module <- First