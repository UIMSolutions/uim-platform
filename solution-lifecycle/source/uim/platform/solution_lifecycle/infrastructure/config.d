/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.infrastructure.config;

import uim.platform.solution_lifecycle;

mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host        = "0.0.0.0";
    ushort port        = 8097;
    string serviceName = "Solution Lifecycle Management Service";
}

SrvConfig loadConfig() {
    import std.process : environment;
    import std.conv    : to;

    SrvConfig cfg;
    auto h = environment.get("SOLUTION_LIFECYCLE_HOST", "");
    if (h.length > 0) cfg.host = h;
    auto p = environment.get("SOLUTION_LIFECYCLE_PORT", "");
    if (p.length > 0) cfg.port = p.to!ushort;
    return cfg;
}
