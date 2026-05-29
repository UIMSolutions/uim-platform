/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.infrastructure.config;
import std.process : environment;
import std.conv    : to;

@safe:

struct AppConfig {
  string host;
  ushort port;
  string serviceName;
}

AppConfig loadConfig() {
  AppConfig cfg;
  cfg.host        = environment.get("MARKET_RATES_HOST", "0.0.0.0");
  cfg.port        = environment.get("MARKET_RATES_PORT", "8096").to!ushort;
  cfg.serviceName = "uim-market-rates-platform-service";
  return cfg;
}
