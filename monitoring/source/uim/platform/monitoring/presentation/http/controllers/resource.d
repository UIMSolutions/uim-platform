/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.resource;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.monitoring.application.usecases.manage.monitored_resources;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.monitored_resource;
// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.presentation.http
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class ResourceController : PlatformController {
  private ManageMonitoredResourcesUseCase usecase;

  this(ManageMonitoredResourcesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

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
      r.tags = getStringArray(j, "tags");
      r.registeredBy = req.headers.get("X-User-Id", "");

      auto result = usecase.register(r);
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
      auto resources = usecase.listResources(tenantId);

      auto arr = resources.map!(resource => resource.toJson).array.toJson;

      auto response = Json.emptyObject
        .set("items", arr)
        .set("totalCount", resources.length);

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      if (!usecase.existsResource(id)) {
        writeError(res, 404, "Resource not found");
        return;
      }

      auto resource = usecase.getResource(id);
      res.writeJsonBody(resource.toJson, 200);
    } catch (Exception e) {
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
      r.tags = getStringArray(j, "tags");

      auto result = usecase.updateResource(id, r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.error == "Resource not found" ? 404 : 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = usecase.removeResource(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("deleted", true);
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
