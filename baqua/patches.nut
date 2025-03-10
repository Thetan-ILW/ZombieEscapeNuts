local base_MaxClients = MaxClients
::MaxClients = function() {
    return base_MaxClients().tointeger()
}