local Component = require("sumika/component")

local begin_hacking_sound = "nier_automata/hacking.mp3"
local hacking_fail_sound = "nier_automata/hacking_fail.mp3"

class Minigame extends Component {
    status = MinigameStatus.None

    // Params
    onComplete = null

    constructor(params){
       base.constructor(params)
       this.status = MinigameStatus.None
    }

    function introSequenceAsync(player) {
        this.status = MinigameStatus.InProgress
        player.PrecacheScriptSound(begin_hacking_sound)
        EmitSoundEx({
            sound_name = begin_hacking_sound,
            entity = player,
            filter_type = 4
        })

        ScreenFade(player, 255, 255, 255, 255, 0.3, 0.3, 2)
        thread.sleep(0.3)
        this.addPlayer(player)
        player.SetScriptOverlayMaterial("sumika/nines_overlay.vmt")
        ScreenFade(player, 255, 255, 255, 255, 0.3, 0.3, 1)
    }

    function outroSequenceAsync(player) {
        this.status = MinigameStatus.Completed
        player.SetScriptOverlayMaterial("")
        ScreenFade(player, 255, 255, 255, 255, 0.3, 0.3, 1)
        this.onComplete(player)
    }

    function failSequenceAsync(player) {
        this.status = MinigameStatus.Failed
        player.PrecacheScriptSound(hacking_fail_sound)
        EmitSoundEx({
            sound_name = hacking_fail_sound,
            entity = player,
            filter_type = 4
        })

        player.SetScriptOverlayMaterial("effects/tvscreen_noise001a.vmt")
        thread.sleep(0.3)
        player.SetScriptOverlayMaterial("")
        ScreenFade(player, 255, 255, 255, 255, 0.3, 0.3, 1)
    }
}

module <- Minigame