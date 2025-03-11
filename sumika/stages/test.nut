local Stage = require("sumika/stage")
local c = require("sumika/stages/components")

local PickUp = require("sumika/components/pick_up")

local Test = class extends Stage {
    function load() {
        addComponent("key", c.Key(Vector(-447, -225, 128), "door"))
        addComponent("key2", c.Key(Vector(-447, -325, 128), "door"))
        addComponent("key3", c.Key(Vector(-447, -425, 128), "door"))
        addComponent("key4", c.Key(Vector(-447, -525, 128), "door"))

        addComponent("trigger", c.KeyTrigger(
            Vector(-448, 272, 128),
            Vector(624, 416, 128),
            "door",
            4,
            function(trigger, player) {
            }
        ))
    }
}

module <- Test