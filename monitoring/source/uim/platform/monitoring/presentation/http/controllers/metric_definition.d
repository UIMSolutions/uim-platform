/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.metric_definition;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.monitoring.application.usecases.manage.metrics;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.metric_definition;
// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.presentation.http.json_utils;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class MetricDefinitionController : PlatformController {
  private ManageMetricsUseCase uc;

  this(ManageMetricsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/metric-definitions", &handleCreate);
    router.get("/api/v1/metric-definitions", &handleList);
    router.get("/api/v1/metric-definitions/*", &handleGetById);
    router.put("/api/v1/metric-definitions/*", &handleUpdate);
    router.delete_("/api/v1/metric-definitions/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateMetricDefinitionRequest r;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.displayName = j.getString("displayName");
      r.description = j.getString("description");
      r.category = j.getString("category");
      r.unit = j.getString("unit");
      r.aggregation = j.getString("aggregation");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.createDefinition(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto defs = uc.listDefinitions(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref d; defs)
        arr ~= serializeDefinition(d);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) defs.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto d = uc.getDefinition(id);
      if (d.id.isEmpty) {
        writeError(res, 404, "Metric definition not found");
        return;
      }
      res.writeJsonBody(serializeDefinition(d), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateMetricDefinitionRequest r;
      r.displayName = j.getString("displayName");
      r.description = j.getString("description");
      r.aggregation = j.getString("aggregation");
      r.isEnabled = j.getBoolean("isEnabled", true);

      auto result = uc.updateDefinition(id, r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, result.error == "Metric definition not found" ? 404 : 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.removeDefinition(id);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeDefinition(const ref MetricDefinition d) {
    auto j = Json.emptyObject;
    j["id"] = Json(d.id);
    j["tenantId"] = Json(d.tenantId);
    j["name"] = Json(d.name);
    j["displayName"] = Json(d.displayName);
    j["description"] = Json(d.description);
    j["category"] = Json(d.category.to!string);
    j["unit"] = Json(d.unit.to!string);
    j["aggregation"] = Json(d.aggregation.to!string);
    j["isCustom"] = Json(d.isCustom);
    j["isEnabled"] = Json(d.isEnabled);
    j["createdBy"] = Json(d.createdBy);
    j["createdAt"] = Json(d.createdAt);
    return j;
  }
}
