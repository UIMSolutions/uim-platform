/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.infrastructure.config;

import std.process : environment;
import std.conv : to;

struct SrvConfig {
  string host        = "0.0.0.0";
  ushort port        = 8115;
  string serviceName = "Keystore Service";
}

SrvConfig loadConfig() {
  SrvConfig config;
  auto hostEnv = environment.get("KEYSTORE_HOST", "");
  if (hostEnv.length > 0)
    config.host = hostEnv;
  auto portEnv = environment.get("KEYSTORE_PORT", "");
  if (portEnv.length > 0) {
    try
      config.port = portEnv.to!ushort;
    catch (Exception) {
    }
  }
  return config;
}
