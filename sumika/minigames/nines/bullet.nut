local Bullet = class {
    owner = null
    isEnemyBullet = false
    entity = null
    direction = null
    endTime = 0
    constructor(entity, direction_degrees, owner, is_enemy_bullet, duration) {
        this.entity = entity
        this.endTime = Time() + duration
        local radians = direction_degrees * (PI / 180)
        this.direction = Vector(-sin(radians), cos(radians), 0)
        this.owner = owner
        this.isEnemyBullet = is_enemy_bullet
    }

    function kill() {
        this.entity.Kill()
    }
}

module <- Bullet