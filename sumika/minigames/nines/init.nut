local Minigame = require("sumika/minigame")
local TemplateSpawner = require("baqua/template_spawner")

local Triangle = require("sumika/minigames/nines/triangle")
local Enemy = require("sumika/minigames/nines/enemy")

local bullet_hit_sound = "nier_automata/nines_bullet_hit.mp3"

class Nines extends Minigame {
    //Params
    arena = null

    triangle = null
    enemies = null
    walls = null
    text = null

    bulletSpeed = 5
    enemyBulletSpeed = 3
    bullets = null
    bulletLimit = 90

    playerZ = 4
    enemyZ = 16
    bulletZ = 8

    startTime = -math.huge

    function load() {
        this.bullets = {}
        this.triangle = null
        this.enemies = {}
        this.walls = []
    }

    function addPlayer(player) {
        this.text = SpawnEntityFromTable("game_text", {
            message = "",
            x = 0.53,
            y = 0.53,
            Effect = "0",
            FadeIn = "0.25",
            FadeOut = "0.5",
            HoldTime = "2",
            channel = 4,
            color = "255 255 255"
        })

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

        local wall_spawner = TemplateSpawner(Entities.FindByName(null, "nines_wall_template"))
        foreach (params in this.arena.walls) {
            local wall = wall_spawner.spawn()
            wall.SetAbsOrigin(params.position)
            wall.SetAbsAngles(params.angle)
            this.walls.append(wall)
        }

        this.startTime = Time()
    }

    function clear() {
        foreach (enemy in this.enemies) {
            enemy.kill()
        }
        foreach (bullet in this.bullets) {
            bullet.kill()
        }
        foreach (wall in this.walls) {
            wall.Kill()
        }

        this.enemies.clear()
        this.bullets.clear()
        this.walls.clear()

        if (this.triangle) {
            this.triangle.kill()
            this.triangle.disableCamera()
            this.triangle = null
        }

        if (this.text) {
            this.text.Kill()
        }
    }

    function kill() {
        this.clear()
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
        local player_entity = this.triangle.player
        local time_left = this.arena.timeLimit - (Time() - this.startTime)

        if (this.enemies.len() == 0) {
            this.killTree()
            thread.coro(@() nines.outroSequenceAsync(player_entity))
        }
        else if (this.triangle.isDead || time_left <= 0) {
            this.clear()
            thread.coro(@() nines.failSequenceAsync(player_entity))
        }
        else {
            this.text.KeyValueFromString("message", format("%0.02f", time_left))
            this.text.AcceptInput("Display", "", player_entity, player_entity)
        }
    }
}

module <- Nines