/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.infrastructure.config;

import std.process : environment;
import uim.platform.usage_data;

// mixin(ShowModule!());
@safe:
/// Service configuration loaded from environment variables.
struct ServiceConfig {
  string host = "0.0.0.0";
  ushort port = 10004;
  string serviceName = "usage-data";
  string apiVersion = "v1";

  static ServiceConfig load() {
    ServiceConfig cfg;
    if (auto h = environment.get("USAGE_DATA_HOST"))
      cfg.host = h;
    if (auto p = environment.get("USAGE_DATA_PORT")) {
      try { cfg.port = p.to!ushort; } catch (Exception) {}
    }
    return cfg;
  }
}
