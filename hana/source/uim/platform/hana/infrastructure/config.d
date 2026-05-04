/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.infrastructure.config;

import std.process : environment;
import std.conv : to;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
struct SrvConfig {
  string host = "0.0.0.0";
  ushort port = 8097;
  string serviceName = "HANA Cloud Service";
}

SrvConfig loadConfig() {
  SrvConfig config;
  auto hostEnv = environment.get("HANA_HOST", "");
  if (hostEnv.length > 0)
    config.host = hostEnv;
  auto portEnv = environment.get("HANA_PORT", "");
  if (portEnv.length > 0) {
    try
      config.port = portEnv.to!ushort;
    catch (Exception) {
    }
  }
  return config;
}
