/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.presentation.http.controllers.policies;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:

class ScalingPolicyController : ManageHttpController {
  private ManageScalingPoliciesUseCase usecase;

  this(ManageScalingPoliciesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/policies", &handleCreate);
    router.get("/api/v1/policies", &handleList);
    router.get("/api/v1/policies/*", &handleGet);
    router.put("/api/v1/policies/*", &handleUpdate);
    router.delete_("/api/v1/policies/*", &handleDelete);
  }

  // POST /api/v1/policies
  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateScalingPolicyRequest r;
    r.appId = data.getString("app_id");
    r.tenantId = data.getString("tenant_id");
    r.instanceMinCount = data.getInteger("instance_min_count");
    r.instanceMaxCount = data.getInteger("instance_max_count");
    r.timezone = data.getString("timezone");
    r.customMetricAllowFrom = data.getString("custom_metric_allow_from");

    auto rulesJ = data["scaling_rules"];
    if (rulesJ.isArray)
      foreach (rdata; rulesJ.toArray) {
        ScalingRuleRequest rr;
        rr.metricType = rdata.getString("metric_type");
        rr.customMetricName = rdata.getString("custom_metric_name");
        rr.threshold = rdata.getInteger("threshold");
        rr.operator = rdata.getString("operator");
        rr.breachDurationSecs = rdata.getInteger("breach_duration_secs");
        rr.coolDownSecs = rdata.getInteger("cool_down_secs");
        rr.adjustment = rdata.getString("adjustment");
        r.scalingRules ~= rr;
      }

    auto recurJ = data["recurring_schedules"];
    if (recurJ.isArray)
      foreach (sdata; recurJ.byValue) {
        RecurringScheduleRequest rs;
        rs.startTime = sdata.getString("start_time");
        rs.endTime = sdata.getString("end_time");
        rs.startDate = sdata.getString("start_date");
        rs.endDate = sdata.getString("end_date");
        rs.instanceMinCount = sdata.getInteger("instance_min_count");
        rs.instanceMaxCount = sdata.getInteger("instance_max_count");
        rs.initialMinInstanceCount = sdata.getInteger("initial_min_instance_count");
        auto dwJ = sj["days_of_week"];
        if (dwJ.isArray)
          foreach (d; dwJ.byValue)
            rs.daysOfWeek ~= d.get!int;
        auto dmJ = sj["days_of_month"];
        if (dmJ.isArray)
          foreach (d; dmJ.byValue)
            rs.daysOfMonth ~= d.get!int;
        r.recurringSchedules ~= rs;
      }

    auto sdJ = data["specific_date_schedules"];
    if (sdJ.isArray)
      foreach (sdata; sdJ.byValue) {
        SpecificDateScheduleRequest sd;
        sd.startDateTime = sdata.getString("start_date_time");
        sd.endDateTime = sdata.getString("end_date_time");
        sd.instanceMinCount = sdata.getInteger("instance_min_count");
        sd.instanceMaxCount = sdata.getInteger("instance_max_count");
        sd.initialMinInstanceCount = sdata.getInteger("initial_min_instance_count");
        r.specificDateSchedules ~= sd;
      }

    auto result = usecase.createPolicy(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    Json.emptyObject.set("id", result.id);
    return successResponse(Json.emptyObject.set("id", result.id), 201);
  }

  // GET /api/v1/policies
  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto policies = usecase.listPolicies(tenantId);
    auto list = policies.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Policy list retrieved successfully", 200, responseData);
  }

  // GET /api/v1/policies/{id}
  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ScalingPolicyId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid policy ID", 400);

    auto policy = usecase.getPolicy(tenantId, id);
    if (policy.isNull)
      return errorResponse("Policy not found", 404);

    auto responseData = policy.toJson();
    return successResponse("Policy retrieved successfully", 200, responseData);
  }

  // PUT /api/v1/policies/{id}
  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ScalingPolicyId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid policy ID", 400);

    auto data = precheck.data;
    UpdateScalingPolicyRequest r;
    r.scalingPolicyId = id;
    r.instanceMinCount = data.getInteger("instance_min_count");
    r.instanceMaxCount = data.getInteger(
      "instance_max_count");
    r.timezone = data.getString("timezone");
    r.customMetricAllowFrom = data
      .getString("custom_metric_allow_from");

    auto rulesJ = j["scaling_rules"];
    if (rulesJ.isArray)
      foreach (rj; rulesJ.toArray) {
        ScalingRuleRequest rr;
        rr.metricType = rdata.getString("metric_type");
        rr.customMetricName = rdata.getString("custom_metric_name");
        rr.threshold = rdata.getInteger(
          "threshold");
        rr.operator = rdata.getString("operator");
        rr.breachDurationSecs = rdata.getInteger(
          "breach_duration_secs");
        rr.coolDownSecs = rdata.getInteger("cool_down_secs");
        rr.adjustment = rdata.getString("adjustment");
        r.scalingRules ~= rr;
      }

    auto result = usecase.updatePolicy(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Policy updated successfully", 200, responseData);
  }

  // DELETE /api/v1/policies/{id}
  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ScalingPolicyId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid policy ID", 400);

    auto result = usecase.deletePolicy(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Policy deleted successfully", 200, responseData);
  }
}
