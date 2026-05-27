/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.metric_definition;




// import uim.platform.monitoring.application.usecases.manage.metrics;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.metric_definition;
// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.presentation.http
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class MetricDefinitionController : ManageController {
  private ManageMetricsUseCase usecase;

  this(ManageMetricsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/metric-definitions", &handleCreate);
    router.get("/api/v1/metric-definitions", &handleList);
    router.get("/api/v1/metric-definitions/*", &handleGet);
    router.put("/api/v1/metric-definitions/*", &handleUpdate);
    router.delete_("/api/v1/metric-definitions/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateMetricDefinitionRequest r;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.displayName = data.getString("displayName");
      r.description = data.getString("description");
      r.category = data.getString("category");
      r.unit = data.getString("unit");
      r.aggregation = data.getString("aggregation");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.createDefinition(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Metric definition created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto defs = usecase.listDefinitions(tenantId);

      auto arr = defs.map!(d => d.toJson).array.toJson;
      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", defs.length)
        .set("message", "Metric definitions retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = MetricDefinitionId(precheck.id);

      auto d = usecase.getDefinition(tenantId, id);
      if (d.isNull) {
        writeError(res, 404, "Metric definition not found");
        return;
      }
      res.writeJsonBody(d.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = MetricDefinitionId(precheck.id);

      auto data = precheck.data;
      UpdateMetricDefinitionRequest request;
      request.tenantId = tenantId;
      request.id = id;
      request.displayName = data.getString("displayName");
      request.description = data.getString("description");
      request.aggregation = data.getString("aggregation");
      request.isEnabled = j.getBoolean("isEnabled", true);

      auto result = usecase.updateDefinition(request);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Metric definition updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.message == "Metric definition not found" ? 404 : 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = MetricDefinitionId(precheck.id);

      auto result = usecase.deleteMetricDefinition(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("deleted", true)
          .set("id", result.id)
          .set("message", "Metric definition deleted successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
