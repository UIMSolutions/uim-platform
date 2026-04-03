module uim.platform.analytics.infrastructure.config;

import uim.platform.analytics;

@safe:
/// Service configuration (read from environment or defaults).
struct ServiceConfig
{
  string host = "0.0.0.0";
  ushort port = 8082;
  string serviceName = "analytics";
  string apiVersion = "v1";

  static ServiceConfig load()
  {
    // import std.process : environment;
    // import std.conv : to;

    ServiceConfig cfg;
    if (auto h = environment.get("ANALYTICS_HOST"))
      cfg.host = h;
    if (auto p = environment.get("ANALYTICS_PORT"))
    {
      try
      {
        cfg.port = p.to!ushort;
      }
      catch (Exception)
      {
      }
    }
    return cfg;
  }
}
