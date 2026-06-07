/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.infrastructure.config;

import std.process : environment;
import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host = "0.0.0.0";
    ushort port = 8119;
}

SrvConfig loadConfig() {
    SrvConfig config;
    config.host = environment.get("CUSTOMER_IDENTITY_HOST", "0.0.0.0");
    config.port = environment.get("CUSTOMER_IDENTITY_PORT", "8119").to!ushort;
    return config;
}
