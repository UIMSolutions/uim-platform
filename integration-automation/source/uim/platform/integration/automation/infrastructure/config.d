/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.infrastructure.config;

/// Service configuration.
struct AppConfig {
  string host = "0.0.0.0";
  ushort port = 8090;
  string serviceName = "Integration Automation Service";
}

/// Load configuration from environment variables.
AppConfig loadConfig() {
  // import std.process : environment;

  AppConfig config;

  auto host = environment.get("CIA_HOST", "");
  if (host.length > 0)
    config.host = host;

  auto portStr = environment.get("CIA_PORT", "");
  if (portStr.length > 0) {
    // import std.conv : to;
    try
      config.port = portStr.to!ushort;
    catch (Exception) {
    }
  }

  return config;
}
