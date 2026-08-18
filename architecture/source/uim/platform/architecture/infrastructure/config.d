module uim.platform.architecture.infrastructure.config;

import std.conv : to;
import std.process : environment;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host = "0.0.0.0";
    ushort port = 8122;
    string serviceName = "Architecture Service";

    /// Storage backend: "MEMORY" | "FILE" | "MONGODB"
    string storageBackend = "MEMORY";

    /// File storage: base directory for JSON flag files
    string fileStoragePath = "/data/architecture";

    /// MongoDB connection string (used when storageBackend == "MONGODB")
    string mongoUri = "mongodb://localhost:27017";
    string mongoDb  = "architecture";

}

SrvConfig loadConfig() {
    SrvConfig cfg;

    auto host = environment.get("ARCHITECTURE_HOST", "");
    if (host.length) cfg.host = host;

    auto portStr = environment.get("ARCHITECTURE_PORT", "");
    if (portStr.length) {
        try cfg.port = portStr.to!ushort;
        catch (ConvException) {}
    }

    auto name = environment.get("ARCHITECTURE_SERVICE_NAME", "");
    if (name.length) cfg.serviceName = name;

    auto backend = environment.get("ARCHITECTURE_STORAGE_BACKEND", "");
    if (backend.length) cfg.storageBackend = backend;

    auto filePath = environment.get("ARCHITECTURE_FILE_PATH", "");
    if (filePath.length) cfg.fileStoragePath = filePath;

    auto mongoUri = environment.get("ARCHITECTURE_MONGO_URI", "");
    if (mongoUri.length) cfg.mongoUri = mongoUri;

    auto mongoDb = environment.get("ARCHITECTURE_MONGO_DB", "");
    if (mongoDb.length) cfg.mongoDb = mongoDb;

    return cfg;

}
