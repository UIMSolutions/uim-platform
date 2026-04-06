/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.config;

import std.process;
import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

struct AppConfig {
    string host = "0.0.0.0";
    ushort port = 8101;
    string serviceName = "Custom Domain Service";
}

AppConfig loadConfig() {
    AppConfig config;
    auto hostEnv = environment.get("CUSTOM_DOMAIN_HOST", "");
    if (hostEnv.length > 0)
        config.host = hostEnv;
    auto portEnv = environment.get("CUSTOM_DOMAIN_PORT", "");
    if (portEnv.length > 0) {
        try
            config.port = portEnv.to!ushort;
        catch (Exception) {
        }
    }
    return config;
}
