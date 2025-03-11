IncludeScript("baqua/baqua", null)
require("sumika/enums")

local main = require("sumika/main")
main.load()

local crashed = false
local event_pool = []

function update() {
    if (crashed)
        return

    foreach (event in event_pool) {
        main.receive(event)
    }
    event_pool.clear()

    main.update()

    return -1
}

local Event = class {
    name = null
    data = null
    constructor(name, data) {
        this.name = name
        this.data = data
    }
}

local event_binds = {
    round_start = GameEvent.RoundStart,
    player_spawn = GameEvent.PlayerSpawn,
    player_death = GameEvent.PlayerDeath
}

::gameEvents <- {}

foreach(name, type in event_binds) {
    local type = type
    gameEvents[format("OnGameEvent_%s", name)] <- function(data) {
        event_pool.append(Event(type, data))
    }
}

__CollectGameEventCallbacks(gameEvents)

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

AddThinkToEnt(self, "update")

if (!GetListenServerHost())
    return

local dev = require("sumika/dev")
foreach(k, v in dev) {
    this[k] <- v
}