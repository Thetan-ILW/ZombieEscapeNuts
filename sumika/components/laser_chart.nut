require("mania/enums")
require("laserchart/enums")

local Component = require("sumika/component")

local ChartImporter = require("nchart/chart_importer")
local LaserNativeNoteFactory = require("laserchart/nchart/laser_native_note_factory")
local GraphicalNoteFactory = require("laserchart/graphic_engine/note_factory")
local GraphicEngine = require("mania/graphic_engine/init")
local CollisionHandler = require("laserchart/scoring/collision_handler")
local TemplateSpawner = require("baqua/template_spawner")

local LaserChart = class extends Component {
    // Params
    hitPosition = null
    noteChartPath = null
    playerHandlers = null
    onComplete = null
    playerSpeed = 1.3
    playfieldRadius = 300
    prepareTime = 6

    laserChart = null
    graphicEngine = null
    collisionHandlers = null
    pointIndexes = null
    startTime = math.huge

    playerManagerEntity = null

    currentPointIndex = 0

    function load() {
        local note_factory = LaserNativeNoteFactory(this.playfieldRadius)
        local importer = ChartImporter(note_factory)
        local note_chart_table = require(this.noteChartPath)
        this.laserChart = importer.import(note_chart_table)

        local template_spawners = {
            [LaserType.Large] = TemplateSpawner(Entities.FindByName(null, "laser_large_template")),
            [LaserType.Small] = TemplateSpawner(Entities.FindByName(null, "laser_small_template")),
            [LaserType.SmallBlade] = TemplateSpawner(Entities.FindByName(null, "laser_blade_small_template")),
            [LaserType.LargeBlade] = TemplateSpawner(Entities.FindByName(null, "laser_blade_large_template")),
            [LaserType.Cross] = TemplateSpawner(Entities.FindByName(null, "laser_cross_template")),
        }

        this.graphicEngine = GraphicEngine(GraphicalNoteFactory(template_spawners, this.hitPosition))
        this.graphicEngine.setNotes(this.laserChart.notes)
        this.graphicEngine.scrollSpeed = 3000
        this.graphicEngine.minTime = 0
        this.graphicEngine.maxTime = 0.95

        this.currentPointIndex = 0
        local last = this.laserChart.layers.absolute[0]
        foreach(i, p in this.laserChart.layers.absolute) {
            if (p.absoluteTime != last.absoluteTime) {
                break
            }
            this.currentPointIndex = i
            last = p
        }

        local audio = "#" + note_chart_table.audio + ".mp3"

        foreach (player_handler in this.playerHandlers) {
            player_handler.entity.PrecacheScriptSound(audio)
            break
        }

        local stage = this.getStage()
        this.playerManagerEntity = Entities.FindByClassname(null, "cs_player_manager")
        this.collisionHandlers = {}

        local _this = this
        // Should not be started on this tick, because loading a chart is slow
        stage.addEvent(this.prepareTime, function () {
            foreach (player_handler in _this.playerHandlers) {
                local player_entity = player_handler.entity
                NetProps.SetPropFloat(player_entity, "m_flLaggedMovementValue", _this.playerSpeed)

                _this.collisionHandlers[player_handler] <- CollisionHandler(
                    _this.laserChart.notes,
                    player_handler,
                    _this.hitPosition,
                    _this
                )
                _this.collisionHandlers[player_handler].setCollisionDeltaTime(1)

                EmitSoundEx({
                    sound_name = audio,
                    entity = player_entity
                    filter_type = 4,
                })
            }

            _this.startTime = Time()
        })
    }

    function findCurrentPointIndex(start_index, time) {
        local layers = this.laserChart.layers
        local current_index = start_index

        for (local i = start_index; i < layers.absolute.len(); i++) {
            local p = layers.absolute[i]
            if (time < p.absoluteTime) {
                break
            }
            current_index = i
        }

        return current_index
    }

    function getVisualTime(time, point_index) {
        local layers = this.laserChart.layers
        local absolute_point = layers.absolute[point_index]
        local visual_point = layers.visual[point_index]
        local absolute_norm = (time - absolute_point.absoluteTime) / absolute_point.duration
        return visual_point.absoluteTime + (visual_point.duration * absolute_norm)
    }

    function update() {
        local player = GetListenServerHost()

        local layers = this.laserChart.layers
        local current_time = Time() - this.startTime

        this.currentPointIndex = this.findCurrentPointIndex(this.currentPointIndex, current_time)
        local absolute_point = layers.absolute[this.currentPointIndex]
        local visual_point = layers.visual[this.currentPointIndex]
        local current_visual_time = this.getVisualTime(current_time, this.currentPointIndex)

        this.graphicEngine.setTime(current_time, current_visual_time)
        this.graphicEngine.setPoints(absolute_point, visual_point)
        this.graphicEngine.update()

        foreach(player_handler, collision_handler in this.collisionHandlers) {
            local player_entity = player_handler.entity
            local ping = NetProps.GetPropIntArray(this.playerManagerEntity, "m_iPing", player_entity.entindex()) * 0.001
            local lerp = NetProps.GetPropFloat(player_entity, "m_fLerpTime")
            // Find points in the past: current_time - (ping + lerp)
            // And then also calculate visual time: current_time - (ping + lerp)
            collision_handler.setTime(current_visual_time)
            collision_handler.update()
        }

        if (current_time > this.laserChart.maxTime + 1) {
            this.chartEnded()
        }
    }

    function chartEnded() {
        foreach(player_handler in this.playerHandlers) {
            NetProps.SetPropFloat(player_handler.entity, "m_flLaggedMovementValue", 1)
        }

        this.killTree()
        this.onComplete()
    }
}

module <- LaserChart