/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.infrastructure.config;

/// Service configuration.
struct AppConfig {
  string host = "0.0.0.0";
  ushort port = 8092;
  string serviceName = "Data Attribute Recommendation Service";
}

/// Load configuration from environment variables.
AppConfig loadConfig() {
  // import std.process : environment;

  AppConfig config;

  auto host = environment.get("DAR_HOST", "");
  if (host.length > 0)
    config.host = host;

  auto portStr = environment.get("DAR_PORT", "");
  if (portStr.length > 0) {
    // import std.conv : to;
    try
      config.port = portStr.to!ushort;
    catch (Exception) {
    }
  }

  return config;
}
