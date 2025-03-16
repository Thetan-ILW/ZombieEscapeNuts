local CollisionHandler = class {
    currentNoteIndex = 0
    notes = null
    playerHandler = null
    playfieldHitPosition = null
    game = null
    collisionDeltaTime = 0.95
    playerRadius = 24.5
    currentTime = -math.huge

    constructor(laser_notes, player_handler, playfield_hit_position, game) {
        this.currentNoteIndex = 0
        this.notes = laser_notes
        this.playerHandler = player_handler
        this.playfieldHitPosition = playfield_hit_position
        this.game = game
        this.currentTime = -math.huge
    }

    function setTime(current_time) {
        this.currentTime = current_time
    }

    function setCollisionDeltaTime(time) {
        this.collisionDeltaTime = time
    }

    function update() {
        local player_entity = this.playerHandler.entity
        local player_pos = player_entity.GetOrigin() - this.playfieldHitPosition

        for (local i = this.currentNoteIndex; i < this.notes.len(); i++) {
            local laser = this.notes[i]
            local delta_time = this.currentTime - laser.getVisualTime()

            if (delta_time < this.collisionDeltaTime)
                return

            this.currentNoteIndex = i + 1

            local hit = false

            switch (laser.type) {
                case LaserType.Small:
                    hit = this.circleIntersection(player_pos, this.playerRadius, 40, laser.position)
                    break
                case LaserType.Large:
                    hit = this.circleIntersection(player_pos, this.playerRadius, 52, laser.position)
                    break
                case LaserType.SmallBlade:
                    hit = this.lineIntersection(player_pos, this.playerRadius * 1.4, laser.position, 320, laser.angle)
                    break
                case LaserType.LargeBlade:
                case LaserType.Cross:
                    hit = this.lineIntersection(player_pos, this.playerRadius * 1.4 laser.position, 1024, laser.angle)
                    break
            }

            if (hit) {
                player_entity.TakeDamage(5, 1, null)
                NetProps.SetPropFloat(player_entity, "m_flVelocityModifier", 1)
            }
        }
    }

    function circleIntersection(c1_origin, c1_radius, c2_radius, c2_origin) {
        local distance = sqrt(pow(c2_origin.x - c1_origin.x, 2) + pow(c2_origin.y - c1_origin.y, 2))
        return distance < c1_radius + c2_radius
    }

    function lineIntersection(circle_center, circle_radius, line_origin, line_length, line_angle_degrees) {
        local angle_radians = line_angle_degrees * (PI / 180)

        local half_length = line_length / 2

        local dx = half_length * cos(angle_radians)
        local dy = half_length * sin(angle_radians)

        local start_point = Vector2D(line_origin.x - dx, line_origin.y - dy)
        local end_point = Vector2D(line_origin.x + dx, line_origin.y + dy)

        local line_vector = end_point - start_point
        local center_vector = circle_center - start_point

        local dot_product = center_vector.x * line_vector.x + center_vector.y * line_vector.y
        local line_vector_squared = pow(line_vector.x, 2) + pow(line_vector.y, 2)

        local t = dot_product / line_vector_squared

        if (t < 0) {
            t = 0
        }
        else if (t > 1) {
            t = 1
        }

        local closest_point = Vector2D(
            start_point.x + t * line_vector.x,
            start_point.y + t * line_vector.y
        )

        local dx_closest = circle_center.x - closest_point.x
        local dy_closest = circle_center.y - closest_point.y
        local distance_squared = pow(dx_closest, 2) + pow(dy_closest, 2)

        return distance_squared <= pow(circle_radius, 2)
    }
}

module <- CollisionHandler