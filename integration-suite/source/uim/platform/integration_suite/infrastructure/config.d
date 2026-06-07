module uim.platform.integration_suite.infrastructure.config;
import std.process : environment;
import uim.platform.integration_suite;

// mixin(ShowModule!());

@safe:

/// Service configuration.
struct SrvConfig {
  string host        = "0.0.0.0";
  ushort port        = 8096;
  string serviceName = "Integration Suite Service";
}

/// Load configuration from environment variables.
SrvConfig loadConfig() {
  SrvConfig config;

  auto host = environment.get("INTEGRATION_SUITE_HOST", "");
  if (host.length > 0)
    config.host = host;

  auto portStr = environment.get("INTEGRATION_SUITE_PORT", "");
  if (portStr.length > 0) {
    import std.conv : to, ConvException;
    try
      config.port = portStr.to!ushort;
    catch (ConvException) {
    }
  }

  return config;
}
