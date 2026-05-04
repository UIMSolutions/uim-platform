/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.meta;

import uim.platform.ai_core;

class MetaController : PlatformController {
  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v2/lm/meta", &handleMeta);
  }

  private void handleMeta(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto j = Json.emptyObject;

    auto logs = Json.emptyObject
      .set("executions", true)
      .set("deployments", true);

    auto caps = Json.emptyObject
      .set("logs", logs)
      .set("multitenant", true)
      .set("shareable", true)
      .set("staticDeployments", false)
      .set("userDeployments", true)
      .set("userExecutions", true)
      .set("executionSchedules", true)
      .set("bulkUpdates", true)
      .set("timeToLiveDeployments", true);

    // AI API capabilities
    auto ttlLimits = Json.emptyObject
      .set("minimum", Json("10m"))
      .set("maximum", Json(-1));

    auto limits = Json.emptyObject
      .set("deployments", ["maxRunningCount": Json(-1)].toJson)
      .set("executions", ["maxRunningCount": Json(-1)].toJson)
      .set("minimumFrequencyHour", Json(1))
      .set("timeToLiveDeployments", ttlLimits);

    auto aiApi = Json.emptyObject
      .set("capabilities", caps)
      .set("limits", limits)
      .set("version", Json("2.18.0"));

    j["aiApi"] = aiApi;

    // Extensions
    auto ext = Json.emptyObject;

    auto analytics = Json.emptyObject;
    analytics["version"] = Json("1.0.0");
    ext["analytics"] = analytics;

    auto metrics = Json.emptyObject;
    auto metricCaps = Json.emptyObject;
    metricCaps["extendedResults"] = Json(true);
    metrics["capabilities"] = metricCaps;
    metrics["version"] = Json("1.0.0");
    ext["metrics"] = metrics;

    auto rgExt = Json.emptyObject;
    rgExt["version"] = Json("1.2.0");
    ext["resourceGroups"] = rgExt;

    j["extensions"] = ext;
    j["runtimeApiVersion"] = Json("2.21.0");
    j["runtimeIdentifier"] = Json("uim-ai-core");

    res.writeJsonBody(j, 200);
  }
}
