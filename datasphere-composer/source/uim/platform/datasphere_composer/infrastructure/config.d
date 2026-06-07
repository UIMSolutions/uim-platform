/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.infrastructure.config;

import uim.platform.datasphere_composer;

// mixin(ShowModule!());

@safe:
struct SrvConfig {
  string host        = "0.0.0.0";
  int    port        = 8099;
  string serviceName = "Datasphere Data Composer";
}

SrvConfig loadConfig() {
  import std.process : environment;
  

  SrvConfig cfg;
  auto host = environment.get("DATASPHERE_COMPOSER_HOST", "");
  if (host.length > 0) cfg.host = host;

  auto port = environment.get("DATASPHERE_COMPOSER_PORT", "");
  if (port.length > 0) {
    try { cfg.port = port.to!int; } catch (Exception) {}
  }
  return cfg;
}
