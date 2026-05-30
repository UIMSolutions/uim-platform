/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.config;

import uim.platform.postgres;
import std.process : environment;


mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host        = "0.0.0.0";
    int    port        = 8131;
    string persistence = "memory";
    string filePath    = "./data";
    string mongoUri    = "mongodb://localhost:27017";
    string mongoDb     = "postgres";
}

SrvConfig loadConfig() @safe {
    SrvConfig cfg;
    auto h = environment.get("POSTGRES_HOST", "");
    if (h.length > 0) cfg.host = h;
    auto p = environment.get("POSTGRES_PORT", "");
    if (p.length > 0) cfg.port = p.to!int;
    auto prs = environment.get("POSTGRES_PERSISTENCE", "");
    if (prs.length > 0) cfg.persistence = prs;
    auto fp = environment.get("POSTGRES_FILE_PATH", "");
    if (fp.length > 0) cfg.filePath = fp;
    auto mu = environment.get("POSTGRES_MONGODB_URI", "");
    if (mu.length > 0) cfg.mongoUri = mu;
    auto md = environment.get("POSTGRES_MONGODB_DB", "");
    if (md.length > 0) cfg.mongoDb = md;
    return cfg;
}
