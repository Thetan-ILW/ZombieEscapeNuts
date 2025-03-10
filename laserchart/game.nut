IncludeScript("baqua/baqua")

local character = Entities.FindByName(null, "character")

function think() {
    character.SetAbsAngles(RotateOrientation(character.GetAbsAngles(), QAngle(0, 1, 0)))
    character.SetAbsOrigin(Vector(704, 576, 192 + sin(Time() * 2) * 20))
    return -1
}

AddThinkToEnt(self, "think")

/*
local perv = null
while (perv = Entities.FindByClassname(perv, "env_sprite")) {
    perv.Kill()
}

local sana_neutral = SpawnEntityFromTable("env_sprite", {
    targetname = "sana_neutral",
    model = "sprites/sana_neutral.vmt",
    rendermode = 1,
    spawnflags = 1,
})

sana_neutral.SetAbsOrigin(Vector(704, 576, 127))
NetProps.SetPropInt(sana_neutral, "m_clrRender", 0xaaffffff)
*/

return
require("mania/enums")
require("laserchart/enums")

local ChartImporter = require("nchart/chart_importer")
local LaserNoteFactory = require("laserchart/nchart/laser_note_factory")
local GraphicalNoteFactory = require("laserchart/graphic_engine/note_factory")
local GraphicEngine = require("mania/graphic_engine/init")
local TemplateSpawner = require("baqua/template_spawner")

local note_factory = LaserNoteFactory()
note_factory.additionalAccumulatedNotes  = 3
local importer = ChartImporter(note_factory)
local chart_table = require("charts/b783b31f4d52fe616e1e31e3a365d82a_1")

local laser_chart = importer.import(chart_table)

local template_spawners = {
    [LaserType.Large] = TemplateSpawner(Entities.FindByName(null, "laser_large_template")),
    [LaserType.Small] = TemplateSpawner(Entities.FindByName(null, "laser_small_template")),
    [LaserType.SmallBlade] = TemplateSpawner(Entities.FindByName(null, "laser_blade_small_template")),
    [LaserType.LargeBlade] = TemplateSpawner(Entities.FindByName(null, "laser_blade_large_template")),
    [LaserType.Cross] = TemplateSpawner(Entities.FindByName(null, "laser_blade_large_template")),
}

local hit_position_entity = Entities.FindByName(null, "laser_hit_position")
local hit_position = Vector(448, -2504, 3000)
hit_position_entity.SetAbsOrigin(hit_position)

local graphic_engine = GraphicEngine(GraphicalNoteFactory(template_spawners, hit_position))
graphic_engine.setNotes(laser_chart.notes)
graphic_engine.scrollSpeed = 2000
graphic_engine.minTime = 0
graphic_engine.maxTime = 2.7

// -------------------------------------------
local prepare_time = 1
local start_time = Time()
local game_speed = Convars.GetFloat("host_timescale")

// IMPORTANT!!!
local current_point_index = 0
local last = laser_chart.layers.absolute[0]
foreach(i, p in laser_chart.layers.absolute) {
    if (p.absoluteTime != last.absoluteTime) {
        break
    }
    current_point_index = i
    last = p
}

local player_mgr = Entities.FindByClassname(null, "cs_player_manager")
local player = GetListenServerHost()

local player_speed = 1.3
NetProps.SetPropFloat(player, "m_flLaggedMovementValue", player_speed)

local lerp = NetProps.GetPropFloat(player, "m_fLerpTime")
graphic_engine.setLerp((lerp + FrameTime()) / game_speed)

function update() {
    local ping = NetProps.GetPropIntArray(player_mgr, "m_iPing", player.entindex()) * 0.001
    local current_time = (Time() - start_time - prepare_time) / game_speed
    current_time -= ping

    local layers = laser_chart.layers
    local absolute_point = layers.absolute[current_point_index]
    local visual_point = layers.visual[current_point_index]

    for (local i = current_point_index; i < layers.absolute.len(); i++) {
        local p = layers.absolute[i]

        if (current_time + lerp < p.absoluteTime) {
            break
        }

        current_point_index = i
        absolute_point = p
        visual_point = layers.visual[i]
    }

    graphic_engine.setTime(current_time)
    graphic_engine.setPoints(absolute_point, visual_point)
    graphic_engine.update()

    //player.TakeDamage(1, 1, null)
    //NetProps.SetPropFloat(player, "m_flVelocityModifier", 1)

    return -1
}

local LegacyAudio = require("laserchart_old/audio")
local audio = LegacyAudio("#" + chart_table.audio + ".mp3")
local audio_offset = -0.015 * 2
local ping = NetProps.GetPropIntArray(player_mgr, "m_iPing", player.entindex()) * 0.001
audio.play(1, prepare_time + chart_table.audioOffset - ping - lerp + audio_offset)
AddThinkToEnt(self, "update")