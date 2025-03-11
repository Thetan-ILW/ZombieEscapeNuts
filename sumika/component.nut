class Component {
    id = null
    killed = false
    parent = null
    children = null

    constructor(params = null) {
        if (params) {
            foreach(key, value in params) {
                if (key in this) {
                    this[key] = value
                }
            }
        }

        this.children = {}
        this.killed = false
    }

    function addChild(id, component) {
        if (id in this.children)
            printl(format("Replacing component %s. Don't do that.", id))

        this.children[id] <- component
        component.id = id
        component.parent = this
        component.load()
        return component
    }

    function updateTree() {
        this.update()

        foreach(key, component in this.children) {
            if (component.killed) {
                delete this.children[key]
                continue
            }

            component.updateTree()
        }
    }

    function handleEvent(event) {
        if (this.receive(event))
            return true

        foreach(component in this.children) {
            if (component.handleEvent(event))
                return true
        }
    }

    function getStage() {
        return this.parent.getStage()
    }

    function load() {}
    function update() {}
    function receive(event) {}
    function kill() {}

    function killTree() {
        foreach (component in this.children) {
            if (!component.killed)
                component.killTree()
        }
        this.kill()
        this.killed = true
    }
}

module <- Component