/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Liveness/readiness: GET /health and GET <restPath>/health.
module uim.platform.task_center.presentation.http.controllers.health;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskCenterHealthController {
  protected Json info;

  this(const TaskCenterConfig config, string securityMode) {
    info = Json.emptyObject;
    info["status"] = "UP";
    info["service"] = config.serviceName;
    info["version"] = config.serviceVersion;
    info["storage"] = config.storage;
    info["security"] = securityMode;
    info["providerSync"] = config.syncIntervalSeconds > 0 ? "every " ~ config.syncIntervalSeconds.to!string ~ "s" : "manual";
  }

  void registerRoutes(URLRouter router, string restPath) {
    router.get("/health", &handle);
    router.get("/" ~ restPath.strip("/") ~ "/health", &handle);
  }

  void handle(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    res.writeJsonBody(info);
  }
}
