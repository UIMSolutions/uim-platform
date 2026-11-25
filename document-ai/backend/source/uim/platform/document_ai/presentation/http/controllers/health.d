/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Liveness/readiness: GET /health and <apiPath>/health (Kubernetes / CF probes).
module uim.platform.document_ai.presentation.http.controllers.health;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class DaiHealthController {
  protected Json info;
  protected ProcessingMetrics metrics;

  this(const DaiConfig config, string securityMode, string extractionMode, ProcessingMetrics metrics = null) {
    this.metrics = metrics;
    info = Json.emptyObject;
    info["status"] = "UP";
    info["service"] = config.serviceName;
    info["version"] = config.serviceVersion;
    info["storage"] = config.storage;
    info["security"] = securityMode;
    info["api"] = config.apiPath ~ "/document-ai";
    info["odata"] = config.odataPath;
    info["extraction"] = extractionMode;
    info["worker"] = config.workerIntervalSeconds > 0 ? "every " ~ config.workerIntervalSeconds.to!string ~ "s" : "inline";
    info["minConfidence"] = config.policy.minConfidence;
  }

  void registerRoutes(URLRouter router, string apiPath) {
    router.get("/health", &handle);
    router.get("/" ~ apiPath.strip("/") ~ "/health", &handle);
  }

  void handle(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    auto j = info.clone;
    if (metrics !is null)
      j["processing"] = metrics.toJson();
    res.headers["Cache-Control"] = "no-store";
    res.writeJsonBody(j);
  }
}
