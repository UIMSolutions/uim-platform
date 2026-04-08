/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.resource;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.monitoring.application.usecases.manage.monitored_resources;
import uim.platform.monitoring.application.dto;
import uim.platform.monitoring.domain.entities.monitored_resource;
import uim.platform.monitoring.domain.types;
import uim.platform.monitoring.presentation.http.json_utils;

class ResourceController {
  private ManageMonitoredResourcesUseCase uc;

  this(ManageMonitoredResourcesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/resources", &handleCreate);
    router.get("/api/v1/resources", &handleList);
    router.get("/api/v1/resources/*", &handleGetById);
    router.put("/api/v1/resources/*", &handleUpdate);
    router.delete_("/api/v1/resources/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      RegisterResourceRequest r;
      r.tenantId = req.getTenantId;
      r.subaccountId = req.headers.get("X-Subaccount-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.resourceType = j.getString("resourceType");
      r.url = j.getString("url");
      r.runtime = j.getString("runtime");
      r.region = j.getString("region");
      r.instanceCount = j.getInteger("instanceCount");
      r.tags = jsonStrArray(j, "tags");
      r.registeredBy = req.headers.get("X-User-Id", "");

      auto result = uc.register(r);
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
      auto resources = uc.listResources(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref r; resources)
        arr ~= serializeResource(r);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) resources.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto r = uc.getResource(id);
      if (r.id.isEmpty) {
        writeError(res, 404, "Resource not found");
        return;
      }
      res.writeJsonBody(serializeResource(r), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateResourceRequest r;
      r.description = j.getString("description");
      r.url = j.getString("url");
      r.runtime = j.getString("runtime");
      r.state = j.getString("state");
      r.instanceCount = j.getInteger("instanceCount");
      r.tags = jsonStrArray(j, "tags");

      auto result = uc.updateResource(id, r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, result.error == "Resource not found" ? 404 : 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.removeResource(id);
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

  private static Json serializeResource(const ref MonitoredResource r) {
    auto j = Json.emptyObject;
    j["id"] = Json(r.id);
    j["tenantId"] = Json(r.tenantId);
    j["subaccountId"] = Json(r.subaccountId);
    j["name"] = Json(r.name);
    j["description"] = Json(r.description);
    j["resourceType"] = Json(r.resourceType.to!string);
    j["state"] = Json(r.state.to!string);
    j["url"] = Json(r.url);
    j["runtime"] = Json(r.runtime);
    j["region"] = Json(r.region);
    j["instanceCount"] = Json(cast(long) r.instanceCount);
    j["tags"] = toJsonArray(r.tags);
    j["registeredBy"] = Json(r.registeredBy);
    j["registeredAt"] = Json(r.registeredAt);
    j["lastSeenAt"] = Json(r.lastSeenAt);
    return j;
  }
}
