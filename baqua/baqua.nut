local t = {}
IncludeScript("baqua/package", t)

::package <- t.module
::require <- ::package.require
::math <- require("baqua/math")
::thread <- require("baqua/thread")
::gameEvents <- require("baqua/event")
::world <- require("baqua/world")

require("baqua/patches")
require("baqua/tests")

