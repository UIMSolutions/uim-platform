/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.infrastructure.config;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
struct SrvConfig {
  string host = "0.0.0.0";
  ushort port = 8086;
  string serviceName = "logistic-management";
  string mongoUri;
  string dataDir;
}

SrvConfig loadConfig() {
  import std.process : environment;
  SrvConfig cfg;
  auto h = environment.get("LOGMGMT_HOST", "");
  if (h.length > 0) cfg.host = h;
  auto p = environment.get("LOGMGMT_PORT", "");
  if (p.length > 0) {
    import std.conv : to, ConvException;
    try { cfg.port = p.to!ushort; } catch (ConvException) {}
  }
  cfg.mongoUri = environment.get("LOGMGMT_MONGO_URI", "");
  cfg.dataDir  = environment.get("LOGMGMT_DATA_DIR", "");
  return cfg;
}
