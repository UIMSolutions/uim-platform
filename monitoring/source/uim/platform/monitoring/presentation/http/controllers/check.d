/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.check;






// import uim.platform.monitoring.application.usecases.manage.health_checks;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.health_check;
// import uim.platform.monitoring.domain.entities.health_check_result;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class CheckController : PlatformController {
  private ManageHealthChecksUseCase usecase;

  this(ManageHealthChecksUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/checks", &handleCreate);
    router.get("/api/v1/checks", &handleList);
    router.get("/api/v1/checks/results/*", &handleGetResults);
    router.get("/api/v1/checks/*", &handleGet);
    router.put("/api/v1/checks/*", &handleUpdate);
    router.delete_("/api/v1/checks/*", &handleDelete);
    router.post("/api/v1/checks/results", &handleRecordResult);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateHealthCheckRequest r;
      r.tenantId = tenantId;
      r.resourceId = j.getString("resourceId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.checkType = j.getString("checkType");
      r.intervalSeconds = j.getInteger("intervalSeconds");
      r.url = j.getString("url");
      r.expectedStatus = j.getString("expectedStatus");
      r.mbeanName = j.getString("mbeanName");
      r.mbeanAttribute = j.getString("mbeanAttribute");
      r.customUrl = j.getString("customUrl");
      r.expectedResponseContains = j.getString("expectedResponseContains");
      r.warningThreshold = getDouble(j, "warningThreshold");
      r.criticalThreshold = getDouble(j, "criticalThreshold");
      r.thresholdOperator = j.getString("thresholdOperator");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.createCheck(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Health check created successfully"); 

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto checks = usecase.listChecks(tenantId);
      auto arr = checks.map!(c => c.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", checks.length)
        .set("message", "Health checks retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = HealthCheckId(extractIdFromPath(req.requestURI));

      auto c = usecase.getCheck(tenantId, id);
      if (c.isNull) {
        writeError(res, 404, "Health check not found");
        return;
      }
      res.writeJsonBody(c.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = HealthCheckId(extractIdFromPath(req.requestURI));

      auto j = req.json;
      UpdateHealthCheckRequest r;
      r.tenantId = tenantId;
      r.description = j.getString("description");
      r.isEnabled = j.getBoolean("isEnabled", true);
      r.intervalSeconds = j.getInteger("intervalSeconds");
      r.url = j.getString("url");
      r.expectedStatus = j.getString("expectedStatus");
      r.warningThreshold = getDouble(j, "warningThreshold");
      r.criticalThreshold = getDouble(j, "criticalThreshold");
      r.thresholdOperator = j.getString("thresholdOperator");

      auto result = usecase.updateCheck(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Health check updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.error == "Health check not found" ? 404 : 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = HealthCheckId(extractIdFromPath(req.requestURI));

      auto result = usecase.deleteCheck(tenantId, id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", id)
          .set("deleted", true)
          .set("message", "Health check deleted successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetRecordResult(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      RecordCheckResultRequest r;
      r.tenantId = tenantId;
      r.checkId = HealthCheckId(j.getString("checkId"));
      r.resourceId = MonitoredResourceId(j.getString("resourceId"));
      r.status = j.getString("status");
      r.value_ = getDouble(j, "value");
      r.message = j.getString("message");
      r.responseTimeMs = j.getInteger("responseTimeMs");
      r.httpStatusCode = j.getInteger("httpStatusCode");

      auto result = usecase.recordResult(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Health check result recorded successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetGetResults(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto checkId = HealthCheckId(extractIdFromPath(req.requestURI));
      auto results = usecase.getResults(tenantId, checkId);

      auto arr = results.map!(result => result.toJson).array.toJson;
      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(results.length))
        .set("message", "Health check results retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
