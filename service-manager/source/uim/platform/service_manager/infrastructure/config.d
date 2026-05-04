module uim.platform.service_manager.infrastructure.config;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host = "0.0.0.0";
    ushort port = 8113;
}

SrvConfig loadConfig() {
    import std.process : environment;
    import std.conv : to;

    SrvConfig config;
    auto host = environment.get("SERVICE_MANAGER_HOST", "0.0.0.0");
    auto port = environment.get("SERVICE_MANAGER_PORT", "8113");
    config.host = host;
    config.port = port.to!ushort;
    return config;
}
