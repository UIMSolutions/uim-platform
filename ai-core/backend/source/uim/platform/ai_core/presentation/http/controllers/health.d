/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Liveness/readiness: GET /health, /api/v1/health (Kubernetes probes) and <aiApiPath>/health.
module uim.platform.ai_core.presentation.http.controllers.health;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class AiCoreHealthController {
  protected Json info;

  this(const AiCoreConfig config, string securityMode) {
    info = Json.emptyObject;
    info["status"] = "UP";
    info["service"] = config.serviceName;
    info["version"] = config.serviceVersion;
    info["storage"] = config.storage;
    info["security"] = securityMode;
    info["aiApi"] = config.aiApiPath;
    info["odata"] = config.odataPath;
    info["reconciler"] = config.reconcileIntervalSeconds > 0 ? "every " ~ config.reconcileIntervalSeconds.to!string ~ "s" : "manual";
  }

  void registerRoutes(URLRouter router, string aiApiPath) {
    router.get("/health", &handle);
    router.get("/api/v1/health", &handle);
    router.get("/" ~ aiApiPath.strip("/") ~ "/health", &handle);
  }

  void handle(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    res.writeJsonBody(info);
  }
}
