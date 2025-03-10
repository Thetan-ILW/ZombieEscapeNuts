function require(path) { // cuz I love lua
    local t = {}
    IncludeScript("laserchart/" + path, t)

    if (!("module" in t)) {
        return t
    }

    local module = t.module
    return module
}

::require <- require
::math <- require("math")
::GameEvents <- require("event")


local PlayContext = require("play_context")
local SelectState = require("states/select")
local GameplayState = require("states/gameplay")
local ResultState = require("states/result")
local LaserChartPlayer = require("laser_chart_player")
local Timer = require("timer")

local Point = require("chart/point")
local getPrimaryTempo = require("chart/primary_tempo")

enum GameState {
    Select,
    Gameplay,
    Result
}

class Game {
    playContext = null
    laserChartPlayer = null

    selectState = null
    gameplayState = null
    resultState = null

    noteChartList = null

    gameState = GameState.Select

    tickTimer = Timer(0)
    players = []

    constructor() {
        this.playContext = PlayContext()
        this.laserChartPlayer = LaserChartPlayer(this)
        //this.selectState = SelectState(this)
        this.gameplayState = GameplayState(this)
        //this.resultState = ResultState(this)

        this.tickTimer.connect(this, "update")
    }

    function load() {
        this.findPlayers()

        this.sv()
    }

    function sv() {
        local note_chart = require("unnamed_pack1/credits")

        note_chart.notes.sort(function(a, b) {
            if (a.time > b.time)
                return 1
            if (a.time < b.time)
                return -1
            return 0
        })
        note_chart.timingPoints.sort(function(a, b) {
            if (a.absoluteTime > b.absoluteTime)
                return 1
            if (a.absoluteTime < b.absoluteTime)
                return -1
            return 0
        })

        local primary_tempo = getPrimaryTempo(note_chart.timingPoints)
        local absolute_points = []
        local visual_points = []

        local current_speed = 1

        if (note_chart.timingPoints.len() != 1) {
            for (local i = 0; i != note_chart.timingPoints.len() - 2; i++) {
                local tp = note_chart.timingPoints[i]
                local ntp = note_chart.timingPoints[i + 1]

                if (tp.tempo)
                    current_speed = tp.tempo / primary_tempo

                local speed = current_speed

                if (tp.velocity)
                    speed = speed * tp.velocity

                absolute_points.append(Point(tp.absoluteTime, ntp.absoluteTime - tp.absoluteTime, speed))
            }
        }
        else {
            error("lol not implemented")
        }

        local current_time = 0
        foreach(p in absolute_points) {
            local duration = p.duration * p.currentSpeed
            current_time += duration
            visual_points.append(Point(current_time, duration, p.currentSpeed))
        }

        local RowConverter = require("converters/row")
        local row_converter = RowConverter(note_chart, this.playContext)

        local LaserChart = require("laser_chart")
        local laser_chart = LaserChart(
            note_chart,
            row_converter.convert()
        )
        laser_chart.audio = "unnamed_pack1/" + laser_chart.audio

        local players_copy = []
        foreach (player in this.players) {
            players_copy.append(player)
        }

        local lc_player = this.laserChartPlayer
        lc_player.setPlayContext(this.playContext)
        lc_player.setPlayers(players_copy)
        lc_player.setChart(laser_chart)
        this.setState(GameState.Gameplay)
        this.gameplayState.start()
    }

    function update() {
        switch(this.gameState) {
            case GameState.Select:
                break
            case GameState.Gameplay:
                this.gameplayState.update()
                break
            case GameState.Result:
                break
        }
    }

    function setState(game_state) {
        this.gameState = game_state
    }

    function findPlayers() {
        this.players = []
        local max_players = MaxClients().tointeger()
        for (local i = 1; i <= max_players ; i++)
        {
            local player = PlayerInstanceFromIndex(i)
            if (player)  {
                this.players.append(player)
            }
        }
    }
}

function createGame() {
    game <- Game()
    game.load()
}