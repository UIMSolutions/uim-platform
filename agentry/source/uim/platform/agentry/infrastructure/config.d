/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.config;
import std.process : environment;

import uim.platform.agentry;

// mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host = "0.0.0.0";
    ushort port = 8117;
}

SrvConfig loadConfig() {
    import std.process : environment;

    SrvConfig config;
    auto host = environment.get("AGENTRY_HOST", "0.0.0.0");
    auto port = environment.get("AGENTRY_PORT", "8117");
    config.host = host;
    config.port = port.to!ushort;
    return config;
}
