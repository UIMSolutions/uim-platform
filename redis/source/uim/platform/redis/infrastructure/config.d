/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.config;

import uim.platform.redis;
import std.process : environment;
import std.conv : to;

mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host = "0.0.0.0";
    int    port = 8130;
}

SrvConfig loadConfig() @safe {
    SrvConfig cfg;
    auto h = environment.get("REDIS_HOST", "");
    if (h.length > 0) cfg.host = h;
    auto p = environment.get("REDIS_PORT", "");
    if (p.length > 0) cfg.port = p.to!int;
    return cfg;
}
