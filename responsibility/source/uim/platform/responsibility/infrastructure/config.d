/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.infrastructure.config;

import std.process : environment;
import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host = "0.0.0.0";
    ushort port = 8118;
}

SrvConfig loadConfig() {
    SrvConfig config;
    config.host = environment.get("RESPONSIBILITY_HOST", "0.0.0.0");
    config.port = environment.get("RESPONSIBILITY_PORT", "8118").to!ushort;
    return config;
}
