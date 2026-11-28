/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Liveness/readiness: GET /health and <apiPath>/health (Kubernetes / CF probes).
module uim.platform.ai_launchpad.presentation.http.controllers.health;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class AilpHealthController {
  protected Json info;
  protected ReconcileMetrics metrics;

  this(const AilpConfig config, string securityMode, string runtimeMode, ReconcileMetrics metrics = null) {
    this.metrics = metrics;
    info = Json.emptyObject;
    info["status"] = "UP";
    info["service"] = config.serviceName;
    info["version"] = config.serviceVersion;
    info["storage"] = config.storage;
    info["security"] = securityMode;
    info["api"] = config.apiPath ~ "/ai-launchpad";
    info["odata"] = config.odataPath;
    info["runtime"] = runtimeMode;
    info["reconcile"] = config.reconcileIntervalSeconds > 0 ? "every " ~ config.reconcileIntervalSeconds.to!string ~ "s"
      : "on demand";
  }

  void registerRoutes(URLRouter router, string apiPath) {
    router.get("/health", &handle);
    router.get("/" ~ apiPath.strip("/") ~ "/health", &handle);
  }

  void handle(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    auto j = info.clone;
    if (metrics !is null) {
      auto w = metrics.toJson();
      w["schedule"] = info["reconcile"];
      j["reconcile"] = w;
    }
    res.headers["Cache-Control"] = "no-store";
    res.writeJsonBody(j);
  }
}
