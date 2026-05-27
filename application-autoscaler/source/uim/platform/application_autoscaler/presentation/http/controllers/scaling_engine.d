/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.presentation.http.controllers.scaling_engine;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

/// Driving adapter for the scaling engine use case.
/// In a real deployment this would be called internally by a metric poller;
/// here it is also exposed as an HTTP endpoint for testing / manual triggers.
class ScalingEngineController : PlatformController {
  private ScalingEngineUseCase usecase;

  this(ScalingEngineUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    // POST /api/v1/scaling/trigger
    router.post("/api/v1/scaling/trigger", &handleTrigger);
  }

  // POST /api/v1/scaling/trigger
  // Body: { "app_id": "...", "metric_type": "cpu", "current_value": 85.0 }
  protected void handleTrigger(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto data = precheck.data;
      TriggerScalingRequest r;
      r.appId        = data.getString("app_id");
      r.metricType   = data.getString("metric_type");
      r.currentValue = j["current_value"].type == Json.Type.float_
        ? j["current_value"].get!double
        : cast(double) j.getInteger("current_value");

      auto result = usecase.triggerScaling(r);
      if (result.success)
        res.writeJsonBody(
          Json.emptyObject
            .set("scaling_history_id", result.id)
            .set("message", "Scaling evaluation completed"), 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
