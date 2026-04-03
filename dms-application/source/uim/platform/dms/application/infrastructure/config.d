module uim.platform.dms.application.infrastructure.config;

import uim.platform.dms.application;
mixin(ShowModule!());
@safe:
/// Service configuration.
struct AppConfig {
  string host = "0.0.0.0";
  ushort port = 8094;
  string serviceName = "DMS Application Service";
}

/// Load configuration from environment variables.
AppConfig loadConfig() {
  // import std.process : environment;

  AppConfig config;

  auto host = environment.get("DMS_HOST", "");
  if (host.length > 0)
    config.host = host;

  auto portStr = environment.get("DMS_PORT", "");
  if (portStr.length > 0) {
    // import std.conv : to;

    try
      config.port = portStr.to!ushort;
    catch (Exception) {
    }
  }

  return config;
}
