/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.config;

// import std.conv : to;
import std.process : environment;
import uim.platform.logging;

mixin(ShowModule!());

@safe:

struct AppConfig {
  string host = "0.0.0.0";
  ushort port = 8094;
  string serviceName = "Cloud Logging Service";
}

AppConfig loadConfig() {
  AppConfig config;

  auto host = environment.get("LOGGING_HOST", "");
  if (host.length > 0)
    config.host = host;

  auto portStr = environment.get("LOGGING_PORT", "");
  if (portStr.length > 0) {
    try
      config.port = portStr.to!ushort;
    catch (Exception) {
    }
  }

  return config;
}
