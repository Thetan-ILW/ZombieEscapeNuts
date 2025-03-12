local Arena = require("sumika/minigames/nines/arena")

local t = []
local a = Arena()
a.playerSpawnPosition = Vector(-9216, 12864, -5056)
a.lowestZ = -5056
a.timeLimit = 40
a.enemies = [
    {
        ai = NinesEnemyAi.FollowPlayer,
        shootingPattern = NinesEnemyShootingPattern.FastStraight,
        position = Vector(-9120, 13216, 0)
    },
    {
        ai = NinesEnemyAi.FollowPlayer,
        shootingPattern = NinesEnemyShootingPattern.FastStraight,
        position = Vector(-9312, 13216, 0)
    },
    {
        ai = NinesEnemyAi.None,
        shootingPattern = NinesEnemyShootingPattern.SlowCross,
        position = Vector(-9216 13312, 0)
    },
    {
        ai = NinesEnemyAi.None,
        shootingPattern = NinesEnemyShootingPattern.SlowCross,
        position = Vector(-9440, 13600, 0)
    },
    {
        ai = NinesEnemyAi.None,
        shootingPattern = NinesEnemyShootingPattern.SlowCross,
        position = Vector(-8992, 13600, 0)
    }
]
t.append(a)

module <- t