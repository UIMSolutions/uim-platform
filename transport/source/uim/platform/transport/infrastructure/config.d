/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.infrastructure.config;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host = "0.0.0.0";
    ushort port = 8117;
}

SrvConfig loadConfig() {
    import std.process : environment;

    SrvConfig config;
    auto host = environment.get("TRANSPORT_HOST", "0.0.0.0");
    auto port = environment.get("TRANSPORT_PORT", "8117");
    config.host = host;
    config.port = port.to!ushort;
    return config;
}
