local Minigame = require("sumika/minigame")
local TemplateSpawner = require("baqua/template_spawner")

local Triangle = require("sumika/minigames/nines/triangle")
local Enemy = require("sumika/minigames/nines/enemy")

local bullet_hit_sound = "nier_automata/nines_bullet_hit.mp3"

class Nines extends Minigame {
    arena = null
    triangle = null
    enemies = null

    bulletSpeed = 5
    enemyBulletSpeed = 3
    bullets = null
    bulletLimit = 90

    playerZ = 4
    enemyZ = 16
    bulletZ = 8

    function addPlayer(player) {
        this.bullets = {}
        this.triangle = null
        this.enemies = {}

        player.PrecacheScriptSound(bullet_hit_sound)

        local position = arena.playerSpawnPosition
        position.z = arena.lowestZ + this.playerZ
        local model = SpawnEntityFromTable("prop_dynamic", {
            model = "models/nines_triangle.mdl",
            origin = position,
            solid = 2
        })

        this.triangle = Triangle(model, player, this)
        this.triangle.enableCamera()

        local circle_enemy_spawner = TemplateSpawner(Entities.FindByName(null, "nines_circle_enemy_template"))

        foreach(enemy in this.arena.enemies) {
            local circle = circle_enemy_spawner.spawn()
            local pos = enemy.position
            pos.z = arena.lowestZ + this.enemyZ
            circle.SetAbsOrigin(pos)
            this.enemies[circle] <- Enemy(circle,
                enemy.ai,
                enemy.shootingPattern,
                this
            )
        }
    }

    function kill() {
        foreach (enemy in this.enemies) {
            enemy.kill()
        }
        foreach (bullet in this.bullets) {
            bullet.kill()
        }

        this.triangle.kill()
        this.triangle.disableCamera()
        this.triangle = null
    }

    function addBullet(bullet) {
        if (this.bullets.len() >= this.bulletLimit) {
            foreach(i, bullet in this.bullets) {
                if (bullet.isEnemyBullet) {
                    bullet.entity.Kill()
                    delete bullet[bullet.entity]
                    break
                }
            }
        }

        local position = bullet.entity.GetOrigin()
        position.z = this.bulletZ + this.arena.lowestZ
        bullet.entity.SetAbsOrigin(position)
        this.bullets[bullet.entity] <- bullet
    }

    function playerBulletHit(bullet, target) {
        EmitSoundEx({
            sound_name = bullet_hit_sound,
            entity = bullet.owner.player,
            filter_type = 4
        })

        if (!(target in this.enemies))
            return

        local enemy = this.enemies[target]
        enemy.takeHit()
    }

    function enemyBulletHit(bullet, target) {
        if (target != this.triangle.entity)
            return

        this.triangle.takeHit()
    }

    function update() {
        if (!this.triangle)
            return

        this.triangle.update()

        foreach (enemy in this.enemies) {
            if (enemy.isDead) {
                enemy.entity.Kill()
                delete this.enemies[enemy.entity]
                continue
            }
            enemy.update()
        }

        local current_time = Time()
        local trace = {
            start = null,
            end = null,
            hullmin = Vector(-8, -8, -this.bulletZ + 1),
            hullmax = Vector(8, 8, 8),
            ignore = null,
            mask = -1
        }

        foreach(bullet in this.bullets) {
            if (current_time > bullet.endTime) {
                bullet.kill()
                delete this.bullets[bullet.entity]
                continue
            }

            local bullet_pos = bullet.entity.GetOrigin()
            local speed = bullet.isEnemyBullet ? this.enemyBulletSpeed : this.bulletSpeed
            local new_position = bullet_pos + bullet.direction * speed

            trace.start = bullet_pos
            trace.end = new_position
            trace.ignore = bullet.owner.entity
            TraceHull(trace)

            if (trace.hit) {
                trace.hit = null

                if (bullet.isEnemyBullet) {
                    this.enemyBulletHit(bullet, trace.enthit)
                }
                else {
                    this.playerBulletHit(bullet, trace.enthit)
                }

                bullet.kill()
                delete this.bullets[bullet.entity]
                continue
            }

            bullet.entity.SetAbsOrigin(new_position)
        }

        local nines = this
        local player = this.triangle.player

        if (this.enemies.len() == 0) {
            this.kill()
            this.stage.addCoroutine(function() {
                nines.outroSequenceAsync(player)
            })
        }
        else if (this.triangle.isDead) {
            this.kill()
            this.stage.addCoroutine(function() {
                nines.failSequenceAsync(player)
            })
        }
    }
}

module <- Nines