/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.config;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host = "0.0.0.0";
    ushort port = 8103;
}

AppConfig loadConfig() {
    import std.process : environment;
    import std.conv : to;

    AppConfig config;
    auto host = environment.get("TASK_CENTER_HOST", "0.0.0.0");
    auto port = environment.get("TASK_CENTER_PORT", "8103");
    config.host = host;
    config.port = port.to!ushort;
    return config;
}
