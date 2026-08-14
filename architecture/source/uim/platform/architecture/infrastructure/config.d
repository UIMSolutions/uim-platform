module uim.platform.architecture.infrastructure.config;

import std.conv : to;
import std.process : environment;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host = "0.0.0.0";
    ushort port = 8122;
}

SrvConfig loadConfig() {
    SrvConfig cfg;
    cfg.host = environment.get("ARCHITECTURE_HOST", "0.0.0.0");
    cfg.port = environment.get("ARCHITECTURE_PORT", "8122").to!ushort;
    return cfg;
}
