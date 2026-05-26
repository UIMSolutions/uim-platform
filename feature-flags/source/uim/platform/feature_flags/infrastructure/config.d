/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.infrastructure.config;

import std.process : environment;
import std.conv    : to, ConvException;

mixin(ShowModule!());

@safe:

/// Runtime configuration loaded from environment variables.
struct SrvConfig {
    string host        = "0.0.0.0";
    ushort port        = 8097;
    string serviceName = "Feature Flags Service";

    /// Storage backend: "MEMORY" | "FILE" | "MONGODB"
    string storageBackend = "MEMORY";

    /// File storage: base directory for JSON flag files
    string fileStoragePath = "/data/feature-flags";

    /// MongoDB connection string (used when storageBackend == "MONGODB")
    string mongoUri = "mongodb://localhost:27017";
    string mongoDb  = "feature_flags";
}

SrvConfig loadConfig() {
    SrvConfig cfg;

    auto host = environment.get("FEATURE_FLAGS_HOST", "");
    if (host.length) cfg.host = host;

    auto portStr = environment.get("FEATURE_FLAGS_PORT", "");
    if (portStr.length) {
        try cfg.port = portStr.to!ushort;
        catch (ConvException) {}
    }

    auto name = environment.get("FEATURE_FLAGS_SERVICE_NAME", "");
    if (name.length) cfg.serviceName = name;

    auto backend = environment.get("FEATURE_FLAGS_STORAGE_BACKEND", "");
    if (backend.length) cfg.storageBackend = backend;

    auto filePath = environment.get("FEATURE_FLAGS_FILE_PATH", "");
    if (filePath.length) cfg.fileStoragePath = filePath;

    auto mongoUri = environment.get("FEATURE_FLAGS_MONGO_URI", "");
    if (mongoUri.length) cfg.mongoUri = mongoUri;

    auto mongoDb = environment.get("FEATURE_FLAGS_MONGO_DB", "");
    if (mongoDb.length) cfg.mongoDb = mongoDb;

    return cfg;
}
