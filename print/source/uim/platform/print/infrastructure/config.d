/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.infrastructure.config;

import uim.platform.print;
import std.process : environment;
mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host = "0.0.0.0";
    ushort port = 8120;
    string dataDir = "/data/print";
    string mongoUri = "mongodb://localhost:27017";
    string mongoDb = "uim_print";
    PersistenceBackend backend = PersistenceBackend.memory;
}

SrvConfig loadConfig() {
    SrvConfig config;
    config.host = environment.get("PRINT_HOST", "0.0.0.0");
    config.port = environment.get("PRINT_PORT", "8120").to!ushort;
    config.dataDir = environment.get("PRINT_DATA_DIR", "/data/print");
    config.mongoUri = environment.get("PRINT_MONGO_URI", "mongodb://localhost:27017");
    config.mongoDb = environment.get("PRINT_MONGO_DB", "uim_print");

    auto backendStr = environment.get("PRINT_BACKEND", "memory");
    switch (backendStr) {
        case "file":    config.backend = PersistenceBackend.file_; break;
        case "mongodb": config.backend = PersistenceBackend.mongodb; break;
        default:        config.backend = PersistenceBackend.memory;
    }
    return config;
}
