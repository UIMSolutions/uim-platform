/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.config;

import std.process : environment;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
/// Service configuration (read from environment or defaults).
struct ServiceConfig {
  string host = "0.0.0.0";
  ushort port = 8082;
  string serviceName = "analytics";
  string apiVersion = "v1";

  static ServiceConfig load() {
    // import std.process : environment;
    // import std.conv : to;

    ServiceConfig cfg;
    if (auto h = environment.get("ANALYTICS_HOST"))
      cfg.host = h;
    if (auto p = environment.get("ANALYTICS_PORT")) {
      try
      {
        cfg.port = p.to!ushort;
      }
      catch (Exception) {
      }
    }
    return cfg;
  }
}
