/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Liveness/readiness: GET /health and <apiPath>/health (Kubernetes probes, CF health check).
module uim.platform.architecture.presentation.http.controllers.health;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class ArchitectureHealthController {
  protected Json info;

  this(const ArchitectureConfig config, string securityMode) {
    info = Json.emptyObject;
    info["status"] = "UP";
    info["service"] = config.serviceName;
    info["version"] = config.serviceVersion;
    info["storage"] = config.storage;
    info["security"] = securityMode;
    info["api"] = config.apiPath;
    info["odata"] = config.odataPath;
  }

  void registerRoutes(URLRouter router, string apiPath) {
    router.get("/health", &handle);
    router.get("/" ~ apiPath.strip("/") ~ "/health", &handle);
  }

  void handle(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    res.writeJsonBody(info);
  }
}
