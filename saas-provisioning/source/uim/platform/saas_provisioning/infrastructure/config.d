/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.infrastructure.config;

import uim.platform.saas_provisioning;
import std.process : environment;


mixin(ShowModule!());

@safe:

/// Runtime configuration for the SaaS Provisioning Service.
struct SrvConfig {
    string host        = "0.0.0.0";
    ushort port        = 8096;
    string serviceName = "SAP SaaS Provisioning Service";
}

/// Load configuration from environment variables, falling back to compiled defaults.
SrvConfig loadConfig() {
    SrvConfig cfg;
    auto h = environment.get("SAAS_PROVISIONING_HOST", "");
    auto p = environment.get("SAAS_PROVISIONING_PORT", "");
    if (h.length > 0) cfg.host = h;
    if (p.length > 0) {
        try { cfg.port = cast(ushort) p.to!int; } catch (Exception) {}
    }
    return cfg;
}
