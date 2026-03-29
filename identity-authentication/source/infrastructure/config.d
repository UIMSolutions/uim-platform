module infrastructure.config;

/// Service configuration.
struct AppConfig
{
    string host = "0.0.0.0";
    ushort port = 8080;
    string jwtSecret = "change-me-in-production-use-env-var";
    int sessionTimeoutHours = 8;
    int tokenExpiryHours = 1;
}

/// Load configuration (extend to read from env vars or config files).
AppConfig loadConfig()
{
    import std.process : environment;

    AppConfig config;

    auto host = environment.get("IAS_HOST", "");
    if (host.length > 0)
        config.host = host;

    auto portStr = environment.get("IAS_PORT", "");
    if (portStr.length > 0)
    {
        import std.conv : to;
        try
            config.port = portStr.to!ushort;
        catch (Exception)
        {
        }
    }

    auto secret = environment.get("IAS_JWT_SECRET", "");
    if (secret.length > 0)
        config.jwtSecret = secret;

    return config;
}
