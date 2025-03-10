local t = require("baqua/tests/test_package")
assert(t.a == 5)

local t2 = require("baqua/tests/test_package")
t2.a = 10
assert(t.a == 10)