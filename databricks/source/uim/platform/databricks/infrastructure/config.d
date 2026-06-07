module uim.platform.databricks.infrastructure.config;
import std.process : environment;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

struct SrvConfig {
  string host        = "0.0.0.0";
  ushort port        = 8104;
  string serviceName = "SAP Databricks Platform Service";
}

SrvConfig loadConfig() {
  SrvConfig config;

  auto host = environment.get("DATABRICKS_HOST", "");
  if (host.length > 0)
    config.host = host;

  auto portStr = environment.get("DATABRICKS_PORT", "");
  if (portStr.length > 0) {
    import std.conv : to, ConvException;
    try
      config.port = portStr.to!ushort;
    catch (ConvException) {
    }
  }

  return config;
}
