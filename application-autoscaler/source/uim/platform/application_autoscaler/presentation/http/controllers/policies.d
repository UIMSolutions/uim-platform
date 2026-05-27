/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.presentation.http.controllers.policies;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class ScalingPolicyController : ManageController {
  private ManageScalingPoliciesUseCase usecase;

  this(ManageScalingPoliciesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/policies",    &handleCreate);
    router.get("/api/v1/policies",     &handleList);
    router.get("/api/v1/policies/*",   &handleGet);
    router.put("/api/v1/policies/*",   &handleUpdate);
    router.delete_("/api/v1/policies/*", &handleDelete);
  }

  // POST /api/v1/policies
  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto data = precheck.data;
      CreateScalingPolicyRequest r;
      r.appId            = data.getString("app_id");
      r.tenantId         = data.getString("tenant_id");
      r.instanceMinCount = j.getInteger("instance_min_count");
      r.instanceMaxCount = j.getInteger("instance_max_count");
      r.timezone         = data.getString("timezone");
      r.customMetricAllowFrom = data.getString("custom_metric_allow_from");

      auto rulesJ = j["scaling_rules"];
      if (rulesJ.type == Json.Type.array)
        foreach (rj; rulesJ.byValue) {
          ScalingRuleRequest rr;
          rr.metricType         = rdata.getString("metric_type");
          rr.customMetricName   = rdata.getString("custom_metric_name");
          rr.threshold          = rj.getInteger("threshold");
          rr.operator           = rdata.getString("operator");
          rr.breachDurationSecs = rj.getInteger("breach_duration_secs");
          rr.coolDownSecs       = rj.getInteger("cool_down_secs");
          rr.adjustment         = rdata.getString("adjustment");
          r.scalingRules       ~= rr;
        }

      auto recurJ = j["recurring_schedules"];
      if (recurJ.type == Json.Type.array)
        foreach (sj; recurJ.byValue) {
          RecurringScheduleRequest rs;
          rs.startTime               = sdata.getString("start_time");
          rs.endTime                 = sdata.getString("end_time");
          rs.startDate               = sdata.getString("start_date");
          rs.endDate                 = sdata.getString("end_date");
          rs.instanceMinCount        = sj.getInteger("instance_min_count");
          rs.instanceMaxCount        = sj.getInteger("instance_max_count");
          rs.initialMinInstanceCount = sj.getInteger("initial_min_instance_count");
          auto dwJ = sj["days_of_week"];
          if (dwJ.type == Json.Type.array)
            foreach (d; dwJ.byValue) rs.daysOfWeek ~= d.get!int;
          auto dmJ = sj["days_of_month"];
          if (dmJ.type == Json.Type.array)
            foreach (d; dmJ.byValue) rs.daysOfMonth ~= d.get!int;
          r.recurringSchedules ~= rs;
        }

      auto sdJ = j["specific_date_schedules"];
      if (sdJ.type == Json.Type.array)
        foreach (sj; sdJ.byValue) {
          SpecificDateScheduleRequest sd;
          sd.startDateTime           = sdata.getString("start_date_time");
          sd.endDateTime             = sdata.getString("end_date_time");
          sd.instanceMinCount        = sj.getInteger("instance_min_count");
          sd.instanceMaxCount        = sj.getInteger("instance_max_count");
          sd.initialMinInstanceCount = sj.getInteger("initial_min_instance_count");
          r.specificDateSchedules   ~= sd;
        }

      auto result = usecase.createPolicy(r);
      if (result.success)
        res.writeJsonBody(
          Json.emptyObject
            .set("id", result.id)
            .set("message", "Scaling policy created successfully"), 201);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/policies
  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto policies = usecase.listPolicies(tenantId);
      auto arr = Json.emptyArray;
      foreach (p; policies) arr ~= p.toJson();
      res.writeJsonBody(
        Json.emptyObject
          .set("items", arr)
          .set("totalCount", policies.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/policies/{id}
  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ScalingPolicyId(extractIdFromPath(req));
      auto p = usecase.getPolicy(tenantId, id);
      if (p.isNull) {
        writeError(res, 404, "Policy not found");
        return;
      }
      res.writeJsonBody(p.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // PUT /api/v1/policies/{id}
  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ScalingPolicyId(extractIdFromPath(req));
      auto data = precheck.data;
      UpdateScalingPolicyRequest r;
      r.scalingPolicyId    = id;
      r.instanceMinCount = j.getInteger("instance_min_count");
      r.instanceMaxCount = j.getInteger("instance_max_count");
      r.timezone         = data.getString("timezone");
      r.customMetricAllowFrom = data.getString("custom_metric_allow_from");

      auto rulesJ = j["scaling_rules"];
      if (rulesJ.type == Json.Type.array)
        foreach (rj; rulesJ.byValue) {
          ScalingRuleRequest rr;
          rr.metricType         = rdata.getString("metric_type");
          rr.customMetricName   = rdata.getString("custom_metric_name");
          rr.threshold          = rj.getInteger("threshold");
          rr.operator           = rdata.getString("operator");
          rr.breachDurationSecs = rj.getInteger("breach_duration_secs");
          rr.coolDownSecs       = rj.getInteger("cool_down_secs");
          rr.adjustment         = rdata.getString("adjustment");
          r.scalingRules       ~= rr;
        }

      auto result = usecase.updatePolicy(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", id).set("message", "Policy updated"), 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // DELETE /api/v1/policies/{id}
  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ScalingPolicyId(extractIdFromPath(req));
      auto result = usecase.deletePolicy(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("message", "Policy deleted"), 200);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
