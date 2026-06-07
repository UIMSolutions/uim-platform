/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.infrastructure.config;

import std.process : environment;


import uim.platform.hana_spatial;

// mixin(ShowModule!());

@safe:
struct SrvConfig {
  string host = "0.0.0.0";
  ushort port = 8098;
  string serviceName = "HANA Spatial Services";
}

SrvConfig loadConfig() {
  SrvConfig config;
  auto hostEnv = environment.get("HANA_SPATIAL_HOST", "");
  if (hostEnv.length > 0)
    config.host = hostEnv;
  auto portEnv = environment.get("HANA_SPATIAL_PORT", "");
  if (portEnv.length > 0) {
    try
      config.port = portEnv.to!ushort;
    catch (Exception) {
    }
  }
  return config;
}
