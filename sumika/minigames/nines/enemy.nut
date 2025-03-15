local Character = require("sumika/minigames/nines/character")
local Bullet = require("sumika/minigames/nines/bullet")

local enemy_purple_bullet = "sumika/sprites/nines_enemy_purple_bullet.vmt"

local Enemy = class extends Character {
    game = null
    ai = null
    shootingPattern = null
    targetTriangle = null
    sizeMin = Vector(-10, -10, -10)
    sizeMax = Vector(10, 10, 4)

    nextShotTime = 0
    currentAngle = 0
    lastHitTime = -math.huge

    constructor(entity, ai, shooting_pattern, game) {
        this.entity = entity
        this.ai = ai
        this.shootingPattern = shooting_pattern
        this.game = game
        this.nextShotTime = 0
        this.currentAngle = 0
        this.maxHits = 20
        this.lastHitTime = -math.huge

        PrecacheModel(enemy_purple_bullet)
    }

    function followTriangle(move = true) {
        local target_position = this.targetTriangle.GetOrigin()
        local current_position = this.entity.GetOrigin()
        local dx = target_position.x - current_position.x
        local dy = target_position.y - current_position.y
        local radians = atan2(dy, dx)
        local degrees = radians * (180 / PI)
        this.entity.SetAbsAngles(QAngle(0, degrees - 90, 0))

        if (!move)
            return

        if (abs(dx) + abs(dy) < 50) {
            return
        }

        local magnitude = sqrt(pow(dx, 2) + pow(dy, 2))
        if (magnitude > 0) {
            this.moveTo(Vector(
                current_position.x + (dx / magnitude),
                current_position.y + (dy / magnitude),
                current_position.z
                )
            )
        }
    }

    function takeHit() {
       base.takeHit()
       this.lastHitTime = Time()
    }

    function bounce() {}

    function shootStraight(interval) {
        if (Time() < this.nextShotTime)
            return
        this.nextShotTime = Time() + interval

        local ent_pos = this.entity.GetOrigin()
        local ent_angle = this.entity.GetAbsAngles()
        local spawn_pos = ent_pos + RotatePosition(ent_pos, ent_angle, Vector(0, 10, 0))
        local angle = RotateOrientation(ent_angle, QAngle(-90, 0, 0))

        local entity = SpawnEntityFromTable("env_sprite", {
            model = enemy_purple_bullet,
            origin = spawn_pos,
            angles = angle,
            rendermode = 2,
        })

        this.game.addBullet(Bullet(entity, ent_angle.y, this, true, 2.5))
    }

    function shootCross(interval) {
        if (Time() < this.nextShotTime)
            return
        this.nextShotTime = Time() + interval

        local ent_pos = this.entity.GetOrigin()
        local ent_angle = this.entity.GetAbsAngles()

        for (local i = 0; i < 4; i++) {
            local degrees = this.currentAngle + (90 * i)
            local spawn_pos = ent_pos + RotatePosition(ent_pos, QAngle(0, degrees, 0), Vector(0, 10, 0))
            local angle = RotateOrientation(ent_angle, QAngle(-90, 0, 0))

            local entity = SpawnEntityFromTable("env_sprite", {
                model = enemy_purple_bullet,
                origin = spawn_pos,
                angles = angle,
                rendermode = 2,
            })

            this.game.addBullet(Bullet(entity, degrees, this, true, 3.5))
        }
    }

    function update() {
        if (!this.game.triangle)
            return
        this.targetTriangle = this.game.triangle.entity

        switch (this.ai) {
            case NinesEnemyAi.None:
                this.followTriangle(false)
                break
            case NinesEnemyAi.FollowPlayer:
                this.followTriangle()
                break
            case NinesEnemyAi.Bounce:
                this.bounce()
                break
            default:
                break
        }

        switch (this.shootingPattern) {
            case NinesEnemyShootingPattern.SlowStraight:
                this.shootStraight(0.5)
                break
            case NinesEnemyShootingPattern.FastStraight:
                this.shootStraight(0.25)
                break
            case NinesEnemyShootingPattern.SlowCross:
                this.shootCross(0.5)
                break
            case NinesEnemyShootingPattern.FastCross:
                this.shootCross(0.25)
                break
            default:
                break
        }

        this.currentAngle += 0.5

        local a = (1 - math.min(1, (Time() - this.lastHitTime) * 3)) * 0.7

        local color = [
            0.3 + a,
            0.3 + a,
            0.3 + a,
            1
        ]

        world.setEntityColor(this.entity, color)
    }
}

module <- Enemy