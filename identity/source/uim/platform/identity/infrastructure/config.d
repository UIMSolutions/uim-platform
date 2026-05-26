/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Runtime configuration loaded from environment variables.
module uim.platform.identity.infrastructure.config;

import uim.platform.identity.domain.enumerations;
import std.process : environment;
import std.conv : to;

@safe:

struct SrvConfig {
    string host = "0.0.0.0";
    ushort port = 8121;
    string dataDir = "/data/identity";
    string mongoUri = "mongodb://localhost:27017";
    string mongoDb = "uim_identity";
    PersistenceBackend backend = PersistenceBackend.memory;
}

SrvConfig loadConfig() {
    SrvConfig cfg;
    auto host = environment.get("IDENTITY_HOST", "");
    if (host.length > 0) cfg.host = host;
    auto port = environment.get("IDENTITY_PORT", "");
    if (port.length > 0) cfg.port = port.to!ushort;
    auto dataDir = environment.get("IDENTITY_DATA_DIR", "");
    if (dataDir.length > 0) cfg.dataDir = dataDir;
    auto mongoUri = environment.get("IDENTITY_MONGO_URI", "");
    if (mongoUri.length > 0) cfg.mongoUri = mongoUri;
    auto mongoDb = environment.get("IDENTITY_MONGO_DB", "");
    if (mongoDb.length > 0) cfg.mongoDb = mongoDb;
    auto backend = environment.get("IDENTITY_BACKEND", "");
    if (backend.length > 0) {
        switch (backend) {
            case "file":    cfg.backend = PersistenceBackend.file_; break;
            case "mongodb": cfg.backend = PersistenceBackend.mongodb; break;
            default:        cfg.backend = PersistenceBackend.memory;
        }
    }
    return cfg;
}
