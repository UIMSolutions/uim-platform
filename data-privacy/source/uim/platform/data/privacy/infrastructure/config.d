module uim.platform.data.privacy.infrastructure.config;

/// Service configuration.
struct AppConfig
{
    string host = "0.0.0.0";
    ushort port = 8089;
    string serviceName = "Data Privacy Integration Service";
}

/// Load configuration from environment variables.
AppConfig loadConfig()
{
    // import std.process : environment;

    AppConfig config;

    auto host = environment.get("DP_HOST", "");
    if (host.length > 0)
        config.host = host;

    auto portStr = environment.get("DP_PORT", "");
    if (portStr.length > 0)
    {
        // import std.conv : to;
        try
            config.port = portStr.to!ushort;
        catch (Exception)
        {
        }
    }

    return config;
}
