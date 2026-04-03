/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.check;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.monitoring.application.usecases.manage_health_checks;
import uim.platform.monitoring.application.dto;
import uim.platform.monitoring.domain.entities.health_check;
import uim.platform.monitoring.domain.entities.health_check_result;
import uim.platform.monitoring.domain.types;
import uim.platform.monitoring.presentation.http.json_utils;

class CheckController : SAPController
{
  private ManageHealthChecksUseCase uc;

  this(ManageHealthChecksUseCase uc)
  {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router)
  {
    super.registerRoutes(router);

    router.post("/api/v1/checks", &handleCreate);
    router.get("/api/v1/checks", &handleList);
    router.get("/api/v1/checks/results/*", &handleGetResults);
    router.get("/api/v1/checks/*", &handleGetById);
    router.put("/api/v1/checks/*", &handleUpdate);
    router.delete_("/api/v1/checks/*", &handleDelete);
    router.post("/api/v1/checks/results", &handleRecordResult);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      CreateHealthCheckRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
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
      r.warningThreshold = jsonDouble(j, "warningThreshold");
      r.criticalThreshold = jsonDouble(j, "criticalThreshold");
      r.thresholdOperator = j.getString("thresholdOperator");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.createCheck(r);
      if (result.success)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto checks = uc.listChecks(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref c; checks)
        arr ~= serializeCheck(c);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) checks.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto c = uc.getCheck(id);
      if (c.id.length == 0)
      {
        writeError(res, 404, "Health check not found");
        return;
      }
      res.writeJsonBody(serializeCheck(c), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateHealthCheckRequest r;
      r.description = j.getString("description");
      r.isEnabled = j.getBoolean("isEnabled", true);
      r.intervalSeconds = j.getInteger("intervalSeconds");
      r.url = j.getString("url");
      r.expectedStatus = j.getString("expectedStatus");
      r.warningThreshold = jsonDouble(j, "warningThreshold");
      r.criticalThreshold = jsonDouble(j, "criticalThreshold");
      r.thresholdOperator = j.getString("thresholdOperator");

      auto result = uc.updateCheck(id, r);
      if (result.success)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, result.error == "Health check not found" ? 404 : 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteCheck(id);
      if (result.success)
      {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRecordResult(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      RecordCheckResultRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.checkId = j.getString("checkId");
      r.resourceId = j.getString("resourceId");
      r.status = j.getString("status");
      r.value_ = jsonDouble(j, "value");
      r.message = j.getString("message");
      r.responseTimeMs = j.getInteger("responseTimeMs");
      r.httpStatusCode = j.getInteger("httpStatusCode");

      auto result = uc.recordResult(r);
      if (result.success)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetResults(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto checkId = extractIdFromPath(req.requestURI);
      auto results = uc.getResults(tenantId, checkId);

      auto arr = Json.emptyArray;
      foreach (ref r; results)
        arr ~= serializeResult(r);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) results.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeCheck(const ref HealthCheck c)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(c.id);
    j["tenantId"] = Json(c.tenantId);
    j["resourceId"] = Json(c.resourceId);
    j["name"] = Json(c.name);
    j["description"] = Json(c.description);
    j["checkType"] = Json(c.checkType.to!string);
    j["isEnabled"] = Json(c.isEnabled);
    j["intervalSeconds"] = Json(cast(long) c.intervalSeconds);
    j["url"] = Json(c.url);
    j["expectedStatus"] = Json(c.expectedStatus);
    j["mbeanName"] = Json(c.mbeanName);
    j["mbeanAttribute"] = Json(c.mbeanAttribute);
    j["customUrl"] = Json(c.customUrl);
    j["warningThreshold"] = Json(c.warningThreshold);
    j["criticalThreshold"] = Json(c.criticalThreshold);
    j["thresholdOperator"] = Json(c.thresholdOperator.to!string);
    j["createdBy"] = Json(c.createdBy);
    j["createdAt"] = Json(c.createdAt);
    j["updatedAt"] = Json(c.updatedAt);
    return j;
  }

  private static Json serializeResult(const ref HealthCheckResult r)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(r.id);
    j["tenantId"] = Json(r.tenantId);
    j["checkId"] = Json(r.checkId);
    j["resourceId"] = Json(r.resourceId);
    j["status"] = Json(r.status.to!string);
    j["value"] = Json(r.value_);
    j["message"] = Json(r.message);
    j["responseTimeMs"] = Json(cast(long) r.responseTimeMs);
    j["httpStatusCode"] = Json(cast(long) r.httpStatusCode);
    j["executedAt"] = Json(r.executedAt);
    return j;
  }
}
