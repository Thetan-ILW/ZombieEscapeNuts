local Component = require("sumika/component")
local TemplateSpawner = require("baqua/template_spawner")
local File = require("baqua/file")

class Parkour extends Component {
    spawners = null
    spawnedParts = 0
    partParams = null

    // Params
    parkourPartParams = null

    function load() {
        this.spawnedParts = 0
        this.partParams = []

        this.spawners = {}
        this.spawners[ParkourPart.Shrine] <- TemplateSpawner(Entities.FindByName(null, "pick_up_shrine_template"))
        this.spawners[ParkourPart.Platform] <- TemplateSpawner(Entities.FindByName(null, "pick_up_platform_template"))
        this.spawners[ParkourPart.Wall] <- TemplateSpawner(Entities.FindByName(null, "pick_up_wall_template"))

        if (!parkourPartParams)
            return

        foreach(i, params in this.parkourPartParams) {
            local x = math.round(params[1], 16)
            local y = math.round(params[2], 16)
            local z = math.round(params[3], 16)
            this.partParams.append({
                type = params[0],
                position = Vector(x, y, z),
                entity = null
            })
        }
    }

    function spawnPart(part_params) {
        local entity = this.spawners[part_params.type].spawn()
        part_params.entity = entity
        this.spawnedParts += 1
    }

    function spawnImmediately() {
        foreach(i, part in this.partParams) {
            this.spawnPart(part_params)
            part.entity.SetAbsOrigin(part_params.position)
        }
    }

    function spawnAnimatedAsync() {
        local start_time = Time()
        local spawn_duration = 2.0
        local spawn_end_time = start_time + spawn_duration
        local animation_duration = 3.0
        local animation_end_time = start_time + animation_duration
        local spawn_position = Vector(1000, -300, 1400)

        while (Time() <= animation_end_time) {
            local spawn_t = (spawn_duration - (spawn_end_time - Time())) / spawn_duration
            local i = math.min(this.partParams.len() - 1, floor((this.partParams.len() - 1) * spawn_t))

            local part = this.partParams[i]

            if(!part.entity) {
                this.spawnPart(part)
            }

            foreach(i, part in this.partParams) {
                if (!part.entity)
                    continue

                local spawn_time = start_time + (i.tofloat() / this.partParams.len().tofloat()) * spawn_duration
                local duration = animation_end_time - spawn_time
                local animation_t = (Time() - spawn_time) / duration
                local cubicout = (1 - pow(1 - animation_t, 3))
                local diff = part.position - spawn_position
                local pos = spawn_position + (diff * cubicout)
                part.entity.SetAbsOrigin(pos)
                world.setEntityColor(part.entity, [1, 1, 1, cubicout])
            }

            suspend()
        }

        foreach (part in this.partParams) {
            if(!part.entity) {
                this.spawnPart(part)
            }

            part.entity.SetAbsOrigin(part.position)
            NetProps.SetPropInt(part.entity, "m_nRenderMode", 0)
        }
    }

    function getShrinePositions() {
        local positions = []

        foreach(part in this.partParams) {
            if (part.type == ParkourPart.Shrine)
                positions.append(part.position)
        }

        return positions
    }

    function devSpawnPart(type, player) {
        local player_angle = player.EyeAngles()
        local player_position = player.GetOrigin()
        local position_front = null
        local height_offset = 0

        switch (type) {
            case ParkourPart.Shrine:
                position_front = Vector(192 + 200, 0, 0)
                height_offset = 160
                break;
            case ParkourPart.Platform:
                position_front = Vector(232, 0, 0)
                height_offset = 48
                break;
            case ParkourPart.Wall:
                position_front = Vector(128, 0, 0)
                height_offset = 64
                break;
            default:
                error(format("Unknown parkour part: %i\n", type))
                return;
        }

        local spawn_pos = player_position + RotatePosition(Vector(player_position.x, player_position.y, 0), player_angle, position_front)
        spawn_pos.x = math.round(spawn_pos.x, 16)
        spawn_pos.y = math.round(spawn_pos.y, 16)
        spawn_pos.z = math.round(spawn_pos.z + height_offset, 16)

        local entity = this.spawners[type].spawn()
        entity.SetAbsOrigin(spawn_pos)
        this.partParams.append({
            type = type,
            position = spawn_pos,
            entity = entity
        })
    }

    function devDeleteInView(player) {
        local start = player.GetOrigin() + Vector(0, 0, 64)
        local end = start + RotatePosition(start, player.EyeAngles(), Vector(1000, 0, 0))

        local trace = {
            start = start,
            end = end,
            ignore = player,
            mask = 33570827
        }
        TraceLineEx(trace)

        if (!trace.hit) {
            DebugDrawLine(start, end, 255, 0, 0, false, 1)
            return
        }

        foreach(i, part in this.partParams) {
            if (trace.enthit == part.entity) {
                part.entity.Kill()
                this.partParams.remove(i)
                return
            }
        }

        DebugDrawLine(start, end, 0, 255, 0, false, 1)
    }

    function devSaveToFile() {
        local str = "[\n"
        foreach (param in this.partParams) {
            local pos = param.position
            str += format("\t[%i, %i, %i, %i],\n", param.type, pos.x, pos.y, pos.z)
        }
        str += "],"
        File.write("parkour", str)
    }

    function kill() {
        foreach (param in this.partParams) {
            if (param.entity) {
                param.entity.Kill()
            }
        }
    }
}

module <- Parkour