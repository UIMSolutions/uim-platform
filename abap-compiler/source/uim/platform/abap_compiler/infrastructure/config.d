/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.infrastructure.config;

import std.process : environment;
import uim.platform.abap_compiler;

// mixin(ShowModule!());

@safe:

/// Service configuration read from environment variables.
/// Defaults align with the UIM Platform port convention.
struct SrvConfig {
    string host        = "0.0.0.0";
    ushort port        = 8093;
    string serviceName = "abap-compiler";
    string apiVersion  = "v1";

    static SrvConfig load() {
        SrvConfig cfg;
        if (auto h = environment.get("ABAPCOMPILER_HOST")) cfg.host = h;
        if (auto p = environment.get("ABAPCOMPILER_PORT")) {
            try { cfg.port = p.to!ushort; } catch (Exception) {}
        }
        return cfg;
    }
}
