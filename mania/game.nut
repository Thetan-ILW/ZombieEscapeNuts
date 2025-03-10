IncludeScript("baqua/baqua")

require("mania/enums")

local ChartImporter = require("nchart/chart_importer")
local ManiaNoteFactory = require("mania/nchart/mania_note_factory")

local TemplateSpawner = require("baqua/template_spawner")
local GraphicEngine = require("mania/graphic_engine/init")
local GraphicalNoteFactory = require("mania/graphic_engine/note_factory")

local NoteHandler = require("mania/note_handler")
local ScoringContainer = require("mania/scoring/scoring_container")

local start = Time()
local importer = ChartImporter(ManiaNoteFactory())
local chart_table = require("charts/828bb3ec485ee67976e1bc136832d858_1")
local note_chart = importer.import(chart_table)

local note_template_spawners = {
    [NoteType.ShortNote] = [
        TemplateSpawner(Entities.FindByName(null, "mania_note_template1"))
        TemplateSpawner(Entities.FindByName(null, "mania_note_template2"))
        TemplateSpawner(Entities.FindByName(null, "mania_note_template3"))
        TemplateSpawner(Entities.FindByName(null, "mania_note_template4"))
    ],
    [NoteType.LongNote] = [
        TemplateSpawner(Entities.FindByName(null, "mania_note_template1"))
        TemplateSpawner(Entities.FindByName(null, "mania_note_template2"))
        TemplateSpawner(Entities.FindByName(null, "mania_note_template3"))
        TemplateSpawner(Entities.FindByName(null, "mania_note_template4"))
    ],
}
local hit_position = 224
local y = 496

local column_positions = [
    Vector(-96, y, hit_position),
    Vector(-32, y, hit_position),
    Vector(32, y, hit_position),
    Vector(96, y, hit_position),
]

local graphic_engine = GraphicEngine(GraphicNoteFactory(note_template_spawners, column_positions))
graphic_engine.setNotes(note_chart.notes)

local scoring_container = ScoringContainer()
local note_handlers = []

for (local i = 0; i < note_chart.columns; i++) {
    note_handlers.append(NoteHandler(note_chart.notes, i, graphic_engine, scoring_container))
}

local current_point_index = 0
local game_speed = Convars.GetFloat("host_timescale")
local prepare_time = 1
local start_time = Time()

// IMPORTANT!!!
local last = note_chart.layers.absolute[0]
foreach(i, p in note_chart.layers.absolute) {
    if (p.absoluteTime != last.absoluteTime) {
        break
    }
    current_point_index = i
    last = p
}

local player = GetListenServerHost()
local buttons_last = 0

local speed_mod = SpawnEntityFromTable("player_speedmod", {
    targetname = "speedmod",
})
speed_mod.AcceptInput("ModifySpeed", "0", player, player)

local base_scoring = scoring_container.scorings["_base"]
local osu_scoring = scoring_container.scorings["osu"]

local counter_alias = {
    perfect = "320",
    great = "300",
    good = "200",
    ok = "100",
    meh = "50",
    miss = "MISS"
}

local counter_colors = {
    perfect = "92 247 247 255",
    great = "240 247 37 255",
    good = "9 222 34 255",
    ok = "12 34 235, 255",
    meh = "166 7 99 255",
    miss = "255 0 0 255"
}

local judge_text = Entities.FindByName(null, "judge_text")
local counters_text = Entities.FindByName(null, "judges_text")
local stats_text = Entities.FindByName(null, "stats_text")
local combo_text = Entities.FindByName(null, "combo_text")
judge_text.KeyValueFromString("message", "")

local lerp = NetProps.GetPropFloat(player, "m_fLerpTime")
graphic_engine.setLerp((lerp + FrameTime()) / game_speed)

local offset = -0.000
local player_mgr = Entities.FindByClassname(null, "cs_player_manager")
function update() {
    local ping = NetProps.GetPropIntArray(player_mgr, "m_iPing", player.entindex()) * 0.001
    local current_time = (Time() - start_time - prepare_time) / game_speed

    local layers = note_chart.layers
    local absolute_point = layers.absolute[current_point_index]
    local visual_point = layers.visual[current_point_index]

    for (local i = current_point_index; i < layers.absolute.len(); i++) {
        local p = layers.absolute[i]

        if (current_time < p.absoluteTime) {
            break
        }

        current_point_index = i
        absolute_point = p
        visual_point = layers.visual[i]
    }

    foreach (note_handler in note_handlers) {
        note_handler.setTime(current_time - ping)
        note_handler.update()
    }

    local buttons = NetProps.GetPropInt(player, "m_nButtons")
	local buttons_changed = buttons_last ^ buttons
	local buttons_pressed = buttons_changed & buttons
	local buttons_released = buttons_changed & (~buttons)
    buttons_last = buttons

    if (buttons_pressed & 512)
        note_handlers[0].keyPressed()
    if (buttons_pressed & 8)
        note_handlers[1].keyPressed()
    if (buttons_pressed & 16)
        note_handlers[2].keyPressed()
    if (buttons_pressed & 1024)
        note_handlers[3].keyPressed()

    graphic_engine.setTime(current_time - ping)
    graphic_engine.setPoints(absolute_point, visual_point)
    graphic_engine.update()

    local c = osu_scoring.hits
    counters_text.KeyValueFromString("message",
        format(
            "osu!mania V1 OD9\n\n320:      %i\n300:      %i\n200:      %i\n100:      %i\n50:       %i\nMISS:     %i",
            c["perfect"],
            c["great"],
            c["good"],
            c["ok"],
            c["meh"],
            c["miss"]
        )
    )

    stats_text.KeyValueFromString("message",
        format(
            "Accuracy:  %0.02f%%\nMax Combo: %i\nMean:      %0.01f ms\n\nMSD:       %0.2f\nStar rate: %0.2f*",
            osu_scoring.accuracy * 100,
            base_scoring.maxCombo,
            base_scoring.mean * 1000
            chart_table.msdDiff[1],
            chart_table.osuDiff
        )
    )

    local counter = osu_scoring.lastCounter
    if (counter) {
        local text = counter_alias[counter]
        judge_text.KeyValueFromString("message", text)
        judge_text.KeyValueFromString("color", counter_colors[counter])
        judge_text.SetAbsOrigin(Vector(-(19 * text.len())/2, 499, 375))
    }

    local combo_str = base_scoring.combo.tostring()
    combo_text.KeyValueFromString("message", combo_str)
    combo_text.SetAbsOrigin(Vector(-(19 * combo_str.len())/2, 499, 327))

    return -1
}

local ping = NetProps.GetPropIntArray(player_mgr, "m_iPing", player.entindex()) * 0.001
local LegacyAudio = require("laserchart_old/audio")
local audio = LegacyAudio("#" + chart_table.audio + ".mp3")
local audio_offset = -0.015 * 2
audio.play(1, prepare_time + chart_table.audioOffset - ping - lerp + audio_offset)

AddThinkToEnt(self, "update")
/*
local player = GetListenServerHost()
local audio_path = "#" + chart_table.audio + ".mp3"
player.PrecacheScriptSound(audio_path) // You probably don't need to precache it on every player

EmitSoundEx({
    sound_name = audio_path,
    entity = player,
})
*/


/*

local Layers = require("nchart/layers")
local GraphicEngine = require("mania/graphic_engine/init")

// ChartImporter class??
local chart = require("laserchart/unnamed_pack1/2050218reek-padorufuckingdiesinamultigenredeathloop")

//

local layers = Layers(chart.timingPoints)

local template_spawners = [
    TemplateSpawner(Entities.FindByName(null, "mania_note_template1"))
    TemplateSpawner(Entities.FindByName(null, "mania_note_template2"))
    TemplateSpawner(Entities.FindByName(null, "mania_note_template3"))
    TemplateSpawner(Entities.FindByName(null, "mania_note_template4"))
]
local note_handlers = []

local graphic_engine = GraphicEngine(template_spawners)
graphic_engine.setNotes(chart.notes, layers)

local audio = LegacyAudio("#unnamed_pack1/" + chart.audio)

local speed_mod = SpawnEntityFromTable("player_speedmod", {
    targetname = "speedmod",
})
local player = GetListenServerHost()
speed_mod.AcceptInput("ModifySpeed", "0", player, player)

local judge_text = Entities.FindByName(null, "judge_text")
local counters_text = Entities.FindByName(null, "judges_text")
local stats_text = Entities.FindByName(null, "stats_text")
local combo_text = Entities.FindByName(null, "combo_text")
judge_text.KeyValueFromString("message", "")

local game_speed = Convars.GetFloat("host_timescale")
local time_offset = game_speed

local prepare_time = 1 * game_speed
local start_time = 0
local current_point_index = 0

function startChart() {
    local lp = layers.absolute[0]
    foreach(i, p in layers.absolute) {
        if (p.absoluteTime != lp.absoluteTime) {
            break
        }
        lp = p
        current_point_index = i
    }

    audio.play(1, prepare_time)
    start_time = Time()
}

startChart()

local buttons_last = 0

/*
    4K: A W S D
    4K: A S E R
    5K: A S D E R
    6K: A S D W E R
    6K: A S D SPACE E R
    7K: A S D SPACE W E R
    7K1S: SHIFT A S D SPACE W E R
*/

/*
local base_scoring = scoring_container.scorings["_base"]
local osu_scoring = scoring_container.scorings["osu"]

local counter_alias = {
    perfect = "320",
    great = "300",
    good = "200",
    ok = "100",
    meh = "50",
    miss = "MISS"
}

local counter_colors = {
    perfect = "92 247 247 255",
    great = "240 247 37 255",
    good = "9 222 34 255",
    ok = "12 34 235, 255",
    meh = "166 7 99 255",
    miss = "255 0 0 255"
}

function update() {
    local current_time = (Time() - start_time - prepare_time) / game_speed

    local absolute_point = layers.absolute[current_point_index]
    local visual_point = layers.visual[current_point_index]

    for (local i = current_point_index; i < layers.absolute.len(); i++) {
        local p = layers.absolute[i]

        if (current_time < p.absoluteTime) {
            break
        }

        current_point_index = i
        absolute_point = p
        visual_point = layers.visual[i]
    }


    foreach (note_handler in note_handlers) {
        note_handler.setTime(current_time)
        note_handler.update()
    }

    local buttons = NetProps.GetPropInt(player, "m_nButtons")
	local buttons_changed = buttons_last ^ buttons
	local buttons_pressed = buttons_changed & buttons
	local buttons_released = buttons_changed & (~buttons)
    buttons_last = buttons

    if (buttons_pressed & 512)
        note_handlers[0].keyPressed()
    if (buttons_pressed & 8)
        note_handlers[1].keyPressed()
    if (buttons_pressed & 16)
        note_handlers[2].keyPressed()
    if (buttons_pressed & 1024)
        note_handlers[3].keyPressed()

    graphic_engine.setTime(current_time)
    graphic_engine.setPoints(absolute_point, visual_point)
    graphic_engine.update()

    local c = osu_scoring.hits
    counters_text.KeyValueFromString("message",
        format(
            "osu!mania V1 OD9\n\n320:      %i\n300:      %i\n200:      %i\n100:      %i\n50:       %i\nMISS:     %i",
            c["perfect"],
            c["great"],
            c["good"],
            c["ok"],
            c["meh"],
            c["miss"]
        )
    )

    stats_text.KeyValueFromString("message",
        format(
            "Accuracy:  %0.02f%%\nMax Combo: %i\nMean:      %0.01f ms\n\nMSD:       %0.2f\nStar rate: %0.2f*",
            osu_scoring.accuracy * 100,
            base_scoring.maxCombo,
            base_scoring.mean * 1000
            chart.msdDiff,
            chart.osuDiff
        )
    )

    local counter = osu_scoring.lastCounter
    if (counter) {
        local text = counter_alias[counter]
        judge_text.KeyValueFromString("message", text)
        judge_text.KeyValueFromString("color", counter_colors[counter])
        judge_text.SetAbsOrigin(Vector(-(19 * text.len())/2, 499, 375))
    }

    local combo_str = base_scoring.combo.tostring()
    combo_text.KeyValueFromString("message", combo_str)
    combo_text.SetAbsOrigin(Vector(-(19 * combo_str.len())/2, 499, 327))

    return -1
}

*/