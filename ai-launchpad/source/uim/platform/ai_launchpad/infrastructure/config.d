/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.config;

import std.process : environment;
import std.conv : to;

struct SrvConfig {
  string host = "0.0.0.0";
  ushort port = 10002;
  string serviceName = "AI Launchpad Service";
}

AppConfig loadConfig() {
  AppConfig config;
  auto hostEnv = environment.get("AILP_HOST", "");
  if (hostEnv.length > 0)
    config.host = hostEnv;
  auto portEnv = environment.get("AILP_PORT", "");
  if (portEnv.length > 0) {
    try
      config.port = portEnv.to!ushort;
    catch (Exception) {
    }
  }
  return config;
}
