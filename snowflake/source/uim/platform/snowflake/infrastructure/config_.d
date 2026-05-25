module uim.platform.snowflake.infrastructure.config_;
import std.process : environment;
import std.conv : to;
mixin(ShowModule!());
@safe:
struct SrvConfig {
  string host        = "0.0.0.0";
  int    port        = 8100;
  string serviceName = "SAP Snowflake";
}

SrvConfig loadConfig() {
  SrvConfig cfg;
  auto h = environment.get("SNOWFLAKE_HOST", "");
  if (h.length > 0) cfg.host = h;
  auto p = environment.get("SNOWFLAKE_PORT", "");
  if (p.length > 0) try { cfg.port = p.to!int; } catch(Exception) {}
  return cfg;
}
