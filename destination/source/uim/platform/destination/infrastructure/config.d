module infrastructure.config;

/// Service configuration.
struct AppConfig
{
    string host = "0.0.0.0";
    ushort port = 8094;
    string serviceName = "Destination Service";
}

/// Load configuration from environment variables.
AppConfig loadConfig()
{
    import std.process : environment;

    AppConfig config;

    auto host = environment.get("DESTINATION_HOST", "");
    if (host.length > 0)
        config.host = host;

    auto portStr = environment.get("DESTINATION_PORT", "");
    if (portStr.length > 0)
    {
        import std.conv : to;
        try
            config.port = portStr.to!ushort;
        catch (Exception)
        {
        }
    }

    return config;
}
