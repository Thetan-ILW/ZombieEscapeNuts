local Character = require("sumika/minigames/nines/character")
local Bullet = require("sumika/minigames/nines/bullet")

local bullet_sprite = "sumika/sprites/nines_bullet.vmt"
local bullet_fire_sound = "nier_automata/nines_fire.mp3"
local damage_sound = "nier_automata/nines_damage.mp3"

local Triangle = class extends Character {
    camera = null
    player = null
    game = null
    mousePosition = null

    sizeMin = Vector(-10, -10, 4)
    sizeMax = Vector(10, 10, 100)
    moveSpeed = 3
    cameraHeight = 300
    cameraOffset = Vector(0, -64, 0)
    shootingInterval = 0.1
    nextShotTime = 0

    constructor(entity, player, game) {
        this.entity = entity
        this.player = player
        this.game = game
        this.mousePosition = Vector()
        this.hits = 0
        this.maxHits = 3
        this.nextShotTime = 0

        PrecacheModel(bullet_sprite)
        player.PrecacheScriptSound(bullet_fire_sound)
        player.PrecacheScriptSound(damage_sound)

        this.camera = SpawnEntityFromTable("point_viewcontrol", {
            spawnflags = 0,
            origin = this.entity.GetOrigin() + this.cameraOffset + Vector(0, 0, this.cameraHeight),
            angles = Vector(75, 90, 0)
        })

        player.SnapEyeAngles(QAngle(0, 0, 0))
    }

    function move(buttons) {
        local move_dir = Vector()

        if (buttons & 512)
            move_dir += Vector(-1, 0, 0)
        if (buttons & 8)
            move_dir += Vector(0, 1, 0)
        if (buttons & 16)
            move_dir += Vector(0, -1, 0)
        if (buttons & 1024)
            move_dir += Vector(1, 0, 0)

        move_dir.Norm()
        local end_position = this.entity.GetOrigin() + (move_dir * this.moveSpeed)
        this.moveTo(end_position)
    }

    function aim() {
        local eye_angles = this.player.EyeAngles()
        local x = eye_angles.Pitch() * 0.6
        local y = eye_angles.Yaw() * 0.6

        this.mousePosition += Vector2D(x, y)
        this.mousePosition.Norm()

        local radians = atan2(this.mousePosition.y, -this.mousePosition.x)
        local degrees = radians * (180 / PI)
        this.entity.SetAbsAngles(QAngle(0, degrees, 0))
    }

    function shoot() {
        if (Time() < this.nextShotTime)
            return
        this.nextShotTime = Time() + this.shootingInterval

        local triangle_pos = this.entity.GetOrigin()
        local triangle_angle = this.entity.GetAbsAngles()
        local spawn_pos = triangle_pos + RotatePosition(triangle_pos, triangle_angle, Vector(0, 20, 0))
        local angle = RotateOrientation(triangle_angle, QAngle(-90, 0, 0))

        local entity = SpawnEntityFromTable("env_sprite", {
            model = bullet_sprite,
            origin = spawn_pos,
            angles = angle,
            rendermode = 5,
        })

        EmitSoundEx({
            sound_name = bullet_fire_sound,
            entity = this.player,
            filter_type = 4
        })

        this.game.addBullet(Bullet(entity, triangle_angle.y, this, false, 1.5))
    }

    function moveCamera() {
        local triangle_pos = this.entity.GetOrigin()
        local dest = triangle_pos + this.cameraOffset
        local diff = (dest - this.camera.GetOrigin()) * 0.92
        local new = dest - diff
        this.camera.SetAbsOrigin(Vector(new.x, new.y, triangle_pos.z + this.cameraHeight))
    }

    function enableCamera() {
        this.camera.AcceptInput("Enable", "", this.player, null)
        NetProps.SetPropFloat(this.player, "m_flLaggedMovementValue", 0)
        NetProps.SetPropInt(this.player, "m_Local.m_iHideHUD", 4)
    }

    function disableCamera() {
        this.camera.AcceptInput("Disable", "", this.player, null)
        NetProps.SetPropFloat(this.player, "m_flLaggedMovementValue", 1)
        NetProps.SetPropInt(this.player, "m_Local.m_iHideHUD", 0)
    }

    function takeHit() {
        base.takeHit()

        if (this.isDead)
            return

        ScreenFade(this.player, 255, 0, 159, 75, 0.18, 0.18, 1)
        EmitSoundEx({
            sound_name = damage_sound,
            entity = this.player,
            filter_type = 4
        })
    }

    function update() {
        if (this.isDead)
            return

        local buttons = NetProps.GetPropInt(this.player, "m_nButtons")

        if (buttons != 0)
            this.move(buttons)

        this.moveCamera()
        this.aim()

        if ((buttons & 1) || (buttons & 131072))
            this.shoot()

        player.SnapEyeAngles(QAngle(0, 0, 0))
    }
}

module <- Triangle