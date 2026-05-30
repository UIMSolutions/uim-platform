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
class CheckController : ManageController {
  private ManageHealthChecksUseCase usecase;

  this(ManageHealthChecksUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/checks", &handleCreate);
    router.get("/api/v1/checks", &handleList);
    router.get("/api/v1/checks/results/*", &handleResults);
    router.get("/api/v1/checks/*", &handleGet);
    router.put("/api/v1/checks/*", &handleUpdate);
    router.delete_("/api/v1/checks/*", &handleDelete);
    router.post("/api/v1/checks/results", &handleRecordResult);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      
      CreateHealthCheckRequest r;
      r.tenantId = tenantId;
      r.resourceId = data.getString("resourceId");
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.checkType = data.getString("checkType");
      r.intervalSeconds = data.getInteger("intervalSeconds");
      r.url = data.getString("url");
      r.expectedStatus = data.getString("expectedStatus");
      r.mbeanName = data.getString("mbeanName");
      r.mbeanAttribute = data.getString("mbeanAttribute");
      r.customUrl = data.getString("customUrl");
      r.expectedResponseContains = data.getString("expectedResponseContains");
      r.warningThreshold = getDouble(j, "warningThreshold");
      r.criticalThreshold = getDouble(j, "criticalThreshold");
      r.thresholdOperator = data.getString("thresholdOperator");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.createCheck(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Health check created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = HealthCheckId(precheck.id);

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

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = HealthCheckId(precheck.id);

      auto data = precheck.data;
      UpdateHealthCheckRequest r;
      r.tenantId = tenantId;
      r.description = data.getString("description");
      r.isEnabled = data.getBoolean("isEnabled", true);
      r.intervalSeconds = data.getInteger("intervalSeconds");
      r.url = data.getString("url");
      r.expectedStatus = data.getString("expectedStatus");
      r.warningThreshold = getDouble(j, "warningThreshold");
      r.criticalThreshold = getDouble(j, "criticalThreshold");
      r.thresholdOperator = data.getString("thresholdOperator");

      auto result = usecase.updateCheck(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Health check updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.message == "Health check not found" ? 404 : 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = HealthCheckId(precheck.id);

      auto result = usecase.deleteCheck(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", id)
          .set("deleted", true)
          .set("message", "Health check deleted successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleRecordResult(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      RecordCheckResultRequest r;
      r.tenantId = tenantId;
      r.checkId = HealthCheckId(data.getString("checkId"));
      r.resourceId = MonitoredResourceId(data.getString("resourceId"));
      r.status = data.getString("status");
      r.value_ = getDouble(j, "value");
      r.message = data.getString("message");
      r.responseTimeMs = data.getInteger("responseTimeMs");
      r.httpStatusCode = data.getInteger("httpStatusCode");

      auto result = usecase.recordResult(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Health check result recorded successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleResults(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto checkId = HealthCheckId(precheck.id);
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
