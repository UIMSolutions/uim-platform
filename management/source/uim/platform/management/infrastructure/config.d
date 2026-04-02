module uim.platform.management.infrastructure.config;
import uim.platform.management;

mixin(ShowModule!());
@safe:
/// Service configuration.
struct AppConfig {
    string host = "0.0.0.0";
    ushort port = 8098;
    string serviceName = "Cloud Management Service";
}

/// Load configuration from environment variables.
AppConfig loadConfig() {
    import std.process : environment;

    AppConfig config;

    auto host = environment.get("MANAGEMENT_HOST", "");
    if (host.length > 0)
        config.host = host;

    auto portStr = environment.get("MANAGEMENT_PORT", "");
    if (portStr.length > 0) {
        import std.conv : to;

        try
            config.port = portStr.to!ushort;
        catch (Exception) {
        }
    }

    return config;
}
