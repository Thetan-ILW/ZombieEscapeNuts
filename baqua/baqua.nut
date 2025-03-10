local t = {}
IncludeScript("baqua/package", t)

::package <- t.module
::require <- ::package.require
::math <- require("baqua/math")
::gameEvents <- require("baqua/event")
::world <- require("baqua/world")

::sleep <- function(duration) {
    local end_time = Time() + duration
    while (Time() < end_time) {
        suspend()
    }
}


require("baqua/patches")
require("baqua/tests")

