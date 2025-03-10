class World {
    function setEntityColor(entity, normal_color) {
        local r = (normal_color[0] * 255).tointeger()
        local g = (normal_color[1] * 255).tointeger()
        local b = (normal_color[2] * 255).tointeger()
        local a = (normal_color[3] * 255).tointeger()
        local color = (r) | (g << 8) | (b << 16) | (a << 24)
        NetProps.SetPropInt(entity, "m_clrRender", color)
    }
}

module <- World