local package = {}
package.loaded <- {}
package.currentlyLoading <- {}
package.ignore <- {}

local function loadScript(path) {
    package.currentlyLoading[path] <- true

    local t = {}
    try {
        IncludeScript(path, t)
    } catch (_){
        return null
    }

    package.currentlyLoading[path] = false
    return t
}

package.require <- function(path) {
    if (path in package.loaded) {
        return package.loaded[path]
    }

    if (path in package.ignore) {
        print(format("Skipping module: '%s'", path))
    }

    if ((path in package.currentlyLoading) && package.currentlyLoading == true) {
        package.ignore[path] <- true
        throw format("require() loop. Module '%s' is not fully loaded and is already required by another module\n", path)
    }

    local m = loadScript(path) || loadScript(path + "/init")

    if (!m)
        throw format("Module not found '%s'\n", path)

    if (!("module" in m))
        return false

    package.loaded[path] <- m.module
    return m.module
}

module <- package