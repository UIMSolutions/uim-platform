/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.config;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host = "0.0.0.0";
    ushort port = 8102;
    string serviceName = "Personal Data Manager Service";
}

SrvConfig loadConfig() {
    import std.process : environment;
    import std.conv : to;

    SrvConfig config;
    config.host = environment.get("PERSONAL_DATA_HOST", "0.0.0.0");
    auto portStr = environment.get("PERSONAL_DATA_PORT", "8102");
    config.port = portStr.to!ushort;
    return config;
}
