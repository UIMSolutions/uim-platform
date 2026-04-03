module uim.platform.identity.provisioning.infrastructure.config;

/// Service configuration.
struct AppConfig {
  string host = "0.0.0.0";
  ushort port = 8093;
  string serviceName = "Identity Provisioning Service";
}

/// Load configuration from environment variables.
AppConfig loadConfig() {
  // import std.process : environment;

  AppConfig config;

  auto host = environment.get("IPS_HOST", "");
  if (host.length > 0)
    config.host = host;

  auto portStr = environment.get("IPS_PORT", "");
  if (portStr.length > 0) {
    // import std.conv : to;

    try
      config.port = portStr.to!ushort;
    catch (Exception) {
    }
  }

  return config;
}
