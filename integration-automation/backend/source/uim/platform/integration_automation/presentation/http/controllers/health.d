/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Liveness/readiness: GET /health and <apiPath>/health (Kubernetes / CF probes).
module uim.platform.integration_automation.presentation.http.controllers.health;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

class IaHealthController {
  protected Json info;

  this(const IaConfig config, string securityMode, string automationMode, string connectivityMode) {
    info = Json.emptyObject;
    info["status"] = "UP";
    info["service"] = config.serviceName;
    info["version"] = config.serviceVersion;
    info["storage"] = config.storage;
    info["security"] = securityMode;
    info["api"] = config.apiPath ~ "/integration-automation";
    info["odata"] = config.odataPath;
    info["automation"] = automationMode;
    info["connectivity"] = connectivityMode;
    info["worker"] = config.workerIntervalSeconds > 0 ? "every " ~ config.workerIntervalSeconds.to!string ~ "s" : "inline";
    info["maxOpenWorkflows"] = config.policy.maxOpenWorkflows;
  }

  void registerRoutes(URLRouter router, string apiPath) {
    router.get("/health", &handle);
    router.get("/" ~ apiPath.strip("/") ~ "/health", &handle);
  }

  void handle(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    res.writeJsonBody(info);
  }
}
