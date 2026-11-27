/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Liveness/readiness: GET /health and <apiPath>/health (Kubernetes / CF probes).
module uim.platform.datasphere.presentation.http.controllers.health;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class DspHealthController {
  protected Json info;
  protected SchedulerMetrics metrics;

  this(const DspConfig config, string securityMode, string processingMode, SchedulerMetrics metrics = null) {
    this.metrics = metrics;
    info = Json.emptyObject;
    info["status"] = "UP";
    info["service"] = config.serviceName;
    info["version"] = config.serviceVersion;
    info["storage"] = config.storage;
    info["security"] = securityMode;
    info["api"] = config.apiPath ~ "/datasphere";
    info["odata"] = config.odataPath;
    info["processingEngine"] = processingMode;
    info["scheduler"] = config.schedulerIntervalSeconds > 0 ? "every " ~ config.schedulerIntervalSeconds.to!string ~ "s"
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
      w["schedule"] = info["scheduler"];
      j["scheduler"] = w;
    }
    res.headers["Cache-Control"] = "no-store";
    res.writeJsonBody(j);
  }
}
