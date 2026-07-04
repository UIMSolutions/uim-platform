/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.infrastructure.config;
import std.process : environment;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host = "0.0.0.0";
    ushort port = 8108;
}

SrvConfig loadConfig() {
    import std.process : environment;

    SrvConfig config;
    auto host = environment.get("MASTERDATA_GOVERNANCE_HOST", "0.0.0.0");
    auto port = environment.get("MASTERDATA_GOVERNANCE_PORT", "8108");
    config.host = host;
    config.port = port.to!ushort;
    return config;
}
