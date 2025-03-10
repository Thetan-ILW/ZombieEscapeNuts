local last_spawned_entity = null

class TemplateSpawner {
    template = null

    constructor(template){
        if (template == null)
            error("Template is null")

        template.ValidateScriptScope()
        local scope = template.GetScriptScope()
        scope.PreSpawnInstance <- function(entity_class, entity_name) { }
        scope.PostSpawn <- function(entities) {
            foreach(_, handle in entities) {
                last_spawned_entity = handle
                break
            }
        }

        this.template = template
    }

    function spawn() {
        this.template.AcceptInput("ForceSpawn", "", null, null)
        local copy = last_spawned_entity
        last_spawned_entity = null
        return copy
    }
}

module <- TemplateSpawner