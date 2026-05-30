/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.config;

import std.process : environment;


@safe:

struct SrvConfig {
    string host      = "0.0.0.0";
    ushort port      = 8132;
    string persistence = "memory";
    string filePath  = "./data";
    string mongoUri  = "mongodb://localhost:27017";
    string mongoDb   = "appevents";
}

SrvConfig loadConfig() @safe {
    SrvConfig cfg;
    cfg.host        = environment.get("APPEVENTS_HOST",        cfg.host);
    cfg.port        = environment.get("APPEVENTS_PORT",        cfg.port.to!string).to!ushort;
    cfg.persistence = environment.get("APPEVENTS_PERSISTENCE", cfg.persistence);
    cfg.filePath    = environment.get("APPEVENTS_FILE_PATH",   cfg.filePath);
    cfg.mongoUri    = environment.get("APPEVENTS_MONGODB_URI", cfg.mongoUri);
    cfg.mongoDb     = environment.get("APPEVENTS_MONGODB_DB",  cfg.mongoDb);
    return cfg;
}
