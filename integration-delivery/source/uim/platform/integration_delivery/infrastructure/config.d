/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.infrastructure.config;

import uim.platform.integration_delivery;
import std.process : environment;


// mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host = "0.0.0.0";
    ushort port = 8120;
}

SrvConfig loadConfig() @trusted {
    SrvConfig cfg;
    auto host = environment.get("INTEGRATION_DELIVERY_HOST", "");
    if (host.length > 0) cfg.host = host;
    auto portStr = environment.get("INTEGRATION_DELIVERY_PORT", "");
    if (portStr.length > 0) cfg.port = portStr.to!ushort;
    return cfg;
}
