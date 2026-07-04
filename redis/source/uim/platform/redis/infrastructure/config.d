/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.config;

import uim.platform.redis;
import std.process : environment;


mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host        = "0.0.0.0";
    int    port        = 8130;
    string persistence = "memory"; // memory | file | mongodb
    string filePath    = "./data";
    string mongoUri    = "mongodb://localhost:27017";
    string mongoDb     = "redis";
}

SrvConfig loadConfig() @safe {
    SrvConfig cfg;
    auto h = environment.get("REDIS_HOST", "");
    if (h.length > 0) cfg.host = h;
    auto p = environment.get("REDIS_PORT", "");
    if (p.length > 0) cfg.port = p.to!int;
    auto prs = environment.get("REDIS_PERSISTENCE", "");
    if (prs.length > 0) cfg.persistence = prs;
    auto fp = environment.get("REDIS_FILE_PATH", "");
    if (fp.length > 0) cfg.filePath = fp;
    auto mu = environment.get("REDIS_MONGODB_URI", "");
    if (mu.length > 0) cfg.mongoUri = mu;
    auto md = environment.get("REDIS_MONGODB_DB", "");
    if (md.length > 0) cfg.mongoDb = md;
    return cfg;
}
