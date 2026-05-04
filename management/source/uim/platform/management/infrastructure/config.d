/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.config;

import std.process : environment;
import uim.platform.management;

mixin(ShowModule!());
@safe:
/// Service configuration.
struct SrvConfig {
  string host = "0.0.0.0";
  ushort port = 8098;
  string serviceName = "Cloud Management Service";
}

/// Load configuration from environment variables.
SrvConfig loadConfig() {
  // import std.process : environment;

  SrvConfig config;

  auto host = environment.get("MANAGEMENT_HOST", "");
  if (host.length > 0)
    config.host = host;

  auto portStr = environment.get("MANAGEMENT_PORT", "");
  if (portStr.length > 0) {
    // import std.conv : to;

    try
      config.port = portStr.to!ushort;
    catch (Exception) {
    }
  }

  return config;
}
