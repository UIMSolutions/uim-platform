/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.config;

// import std.process : environment;
// import std.conv : to;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
struct SrvConfig {
    string host = "0.0.0.0";
    ushort port = 8099;
    string serviceName = "Process Automation Service";
}

SrvConfig loadConfig() {
    SrvConfig config;
    auto hostEnv = environment.get("PROCESS_AUTOMATION_HOST", "");
    if (hostEnv.length > 0)
        config.host = hostEnv;
    auto portEnv = environment.get("PROCESS_AUTOMATION_PORT", "");
    if (portEnv.length > 0) {
        try
            config.port = portEnv.to!ushort;
        catch (Exception) {
        }
    }
    return config;
}
