/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.check;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.monitoring.application.usecases.manage.health_checks;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.health_check;
// import uim.platform.monitoring.domain.entities.health_check_result;
// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.presentation.http.json_utils;
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
    router.get("/api/v1/checks/*", &handleGetById);
    router.put("/api/v1/checks/*", &handleUpdate);
    router.delete_("/api/v1/checks/*", &handleDelete);
    router.post("/api/v1/checks/results", &handleRecordResult);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateHealthCheckRequest r;
      r.tenantId = req.getTenantId;
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
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = usecase.createCheck(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto checks = usecase.listChecks(tenantId);
      auto arr = checks.map!(c => serializeCheck(c)).array;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(checks.length));

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto c = usecase.getCheck(id);
      if (c.isNull) {
        writeError(res, 404, "Health check not found");
        return;
      }
      res.writeJsonBody(serializeCheck(c), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateHealthCheckRequest r;
      r.description = j.getString("description");
      r.isEnabled = j.getBoolean("isEnabled", true);
      r.intervalSeconds = j.getInteger("intervalSeconds");
      r.url = j.getString("url");
      r.expectedStatus = j.getString("expectedStatus");
      r.warningThreshold = getDouble(j, "warningThreshold");
      r.criticalThreshold = getDouble(j, "criticalThreshold");
      r.thresholdOperator = j.getString("thresholdOperator");

      auto result = usecase.updateCheck(id, r);
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

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = usecase.deleteCheck(id);
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

  private void handleRecordResult(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      RecordCheckResultRequest r;
      r.tenantId = req.getTenantId;
      r.checkId = j.getString("checkId");
      r.resourceId = j.getString("resourceId");
      r.status = j.getString("status");
      r.value_ = getDouble(j, "value");
      r.message = j.getString("message");
      r.responseTimeMs = j.getInteger("responseTimeMs");
      r.httpStatusCode = j.getInteger("httpStatusCode");

      auto result = usecase.recordResult(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetResults(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto checkId = extractIdFromPath(req.requestURI);
      auto results = usecase.getResults(tenantId, checkId);

      auto arr = results.map!(result => serializeResult(r)).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(results.length));

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeCheck(const ref HealthCheck c) {
    return Json.emptyObject
      .set("id", c.id)
      .set("tenantId", c.tenantId)
      .set("resourceId", c.resourceId)
      .set("name", c.name)
      .set("description", c.description)
      .set("checkType", c.checkType.to!string)
      .set("isEnabled", c.isEnabled)
      .set("intervalSeconds", c.intervalSeconds)
      .set("url", c.url)
      .set("expectedStatus", c.expectedStatus)
      .set("mbeanName", c.mbeanName)
      .set("mbeanAttribute", c.mbeanAttribute)
      .set("customUrl", c.customUrl)
      .set("warningThreshold", c.warningThreshold)
      .set("criticalThreshold", c.criticalThreshold)
      .set("thresholdOperator", c.thresholdOperator.to!string)
      .set("createdBy", c.createdBy)
      .set("createdAt", c.createdAt)
      .set("updatedAt", c.updatedAt);
  }

  private static Json serializeResult(const ref HealthCheckResult r) {
    return Json.emptyObject
      .set("id", r.id)
      .set("tenantId", r.tenantId)
      .set("checkId", r.checkId)
      .set("resourceId", r.resourceId)
      .set("status", r.status.to!string)
      .set("value", r.value_)
      .set("message", r.message)
      .set("responseTimeMs", r.responseTimeMs)
      .set("httpStatusCode", r.httpStatusCode)
      .set("executedAt", r.executedAt);
  }
}
