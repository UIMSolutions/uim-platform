/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.infrastructure.config;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

struct AppConfig {
    string host = "0.0.0.0";
    ushort port = 8105;
}

AppConfig loadConfig() {
    import std.process : environment;
    import std.conv : to;

    AppConfig config;
    auto host = environment.get("ASSET_STRATEGY_PERFORMANCE_HOST", "0.0.0.0");
    auto port = environment.get("ASSET_STRATEGY_PERFORMANCE_PORT", "8105");
    config.host = host;
    config.port = port.to!ushort;
    return config;
}
