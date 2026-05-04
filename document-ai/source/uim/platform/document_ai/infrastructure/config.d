/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.config;

// import std.process : environment;
// import std.conv : to;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
struct SrvConfig {
  string host = "0.0.0.0";
  ushort port = 8096;
  string serviceName = "Document AI Service";
}

SrvConfig loadConfig() {
  SrvConfig config;
  auto hostEnv = environment.get("DOCAI_HOST", "");
  if (hostEnv.length > 0)
    config.host = hostEnv;
  auto portEnv = environment.get("DOCAI_PORT", "");
  if (portEnv.length > 0) {
    try
      config.port = portEnv.to!ushort;
    catch (Exception) {
    }
  }
  return config;
}
