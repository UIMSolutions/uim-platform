module uim.platform.data_retention.infrastructure.config;

import std.process : environment;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct SrvConfig {
    string host = "0.0.0.0";
    ushort port = 8112;
    string serviceName = "Data Retention Manager Service";
}

SrvConfig loadConfig() {
    SrvConfig config;

    auto host = environment.get("DATA_RETENTION_HOST", "");
    if (host.length > 0) config.host = host;

    auto portStr = environment.get("DATA_RETENTION_PORT", "");
    if (portStr.length > 0) {
        try config.port = portStr.to!ushort;
        catch (Exception) {}
    }

    return config;
}
