/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.config;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host = "0.0.0.0";
    ushort port = 8108;
}

AppConfig loadConfig() {
    import std.process : environment;
    import std.conv : to;

    AppConfig config;
    auto host = environment.get("EVENT_MESH_HOST", "0.0.0.0");
    auto port = environment.get("EVENT_MESH_PORT", "8108");
    config.host = host;
    config.port = port.to!ushort;
    return config;
}
