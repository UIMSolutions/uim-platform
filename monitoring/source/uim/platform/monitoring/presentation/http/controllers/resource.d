/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.resource;




// import uim.platform.monitoring.application.usecases.manage.monitored_resources;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.monitored_resource;
// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.presentation.http
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class ResourceController : ManageController {
  private ManageMonitoredResourcesUseCase usecase;

  this(ManageMonitoredResourcesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/resources", &handleCreate);
    router.get("/api/v1/resources", &handleList);
    router.get("/api/v1/resources/*", &handleGet);
    router.put("/api/v1/resources/*", &handleUpdate);
    router.delete_("/api/v1/resources/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      RegisterResourceRequest r;
      r.tenantId = tenantId;
      r.subaccountId = SubaccountId(req.headers.get("X-Subaccount-Id", ""));
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.resourceType = data.getString("resourceType");
      r.url = data.getString("url");
      r.runtime = data.getString("runtime");
      r.region = data.getString("region");
      r.instanceCount = j.getInteger("instanceCount");
      r.tags = getStrings(j, "tags");
      r.registeredBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.register(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
        .set("id", result.id)
        .set("message", "Resource created successfully");
        
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
      auto resources = usecase.listResources(tenantId);

      auto arr = resources.map!(resource => resource.toJson).array.toJson;

      auto response = Json.emptyObject
        .set("items", arr)
        .set("totalCount", resources.length)
        .set("message", "Resources retrieved successfully");

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = MonitoredResourceId(precheck.id);

      if (!usecase.existsResource(tenantId, id)) {
        writeError(res, 404, "Resource not found");
        return;
      }

      auto resource = usecase.getResource(tenantId, id);
      res.writeJsonBody(resource.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = MonitoredResourceId(precheck.id);
      auto data = precheck.data;

      UpdateResourceRequest r;
      r.tenantId = tenantId;
      r.resourceId = id;
      r.description = data.getString("description");
      r.url = data.getString("url");
      r.runtime = data.getString("runtime");
      r.state = data.getString("state");
      r.instanceCount = j.getInteger("instanceCount");
      r.tags = getStrings(j, "tags");

      auto result = usecase.updateResource(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Resource updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.message == "Resource not found" ? 404 : 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = MonitoredResourceId(precheck.id);

      auto result = usecase.deleteMonitoredResource(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("deleted", true)
          .set("message", "Resource deleted successfully");
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
