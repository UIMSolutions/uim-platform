/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.web.handlers.health;

// import vibe.http.server;
// import vibe.data.json;
@safe:

class HealthHandler {
  void check(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    auto j = Json.emptyObject;
    j["status"] = "healthy";
    j["service"] = "analytics";
    j["version"] = "1.0.0";
    res.writeJsonBody(j);
  }
}
