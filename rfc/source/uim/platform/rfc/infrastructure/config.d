/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.infrastructure.config;

import uim.platform.rfc;

// mixin(ShowModule!());
@safe:

struct SrvConfig {
    string host        = "0.0.0.0";
    ushort port        = 8092;
    string serviceName = "rfc";

    static SrvConfig load() @trusted {
        import std.process : environment;
        import std.conv    : to;
        SrvConfig c;
        auto h = environment.get("RFC_HOST", "");
        if (h.length > 0) c.host = h;
        auto p = environment.get("RFC_PORT", "");
        if (p.length > 0) c.port = p.to!ushort;
        return c;
    }
}
