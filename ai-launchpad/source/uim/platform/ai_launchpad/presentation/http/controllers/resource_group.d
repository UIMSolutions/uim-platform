/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.resource_group;

// import uim.platform.ai_launchpad.application.usecases.manage.resource_groups;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class ResourceGroupController : PlatformController {
  private ManageResourceGroupsUseCase usecase;

  this(ManageResourceGroupsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/admin/resource-groups", &handleCreate);
    router.get("/api/v1/admin/resource-groups", &handleList);
    router.get("/api/v1/admin/resource-groups/*", &handleGet);
    router.patch("/api/v1/admin/resource-groups/*", &handlePatch);
    router.delete_("/api/v1/admin/resource-groups/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      CreateResourceGroupRequest r;
      r.connectionId = connectionId;
      r.resourceGroupId = j.getString("resourceGroupId");
      r.labels = jsonPairArray(j, "labels");

      auto result = usecase.createResourceGroup(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Resource group created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      auto groups = connectionId.isEmpty
        ? usecase.listResourceGroups(tenantId)
        : usecase.listResourceGroups(tenantId, connectionId);

      auto jarr = groups.map!(g => g.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("count", groups.length)
        .set("resources", jarr)
        .set("message", "Resource groups retrieved");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
      auto id = ResourceGroupId(extractIdFromPath(req.requestURI.to!string));

      auto g = usecase.getResourceGroup(tenantId, connectionId, id);
      if (g.isNull) {
        writeError(res, 404, "Resource group not found");
        return;
      }

      res.writeJsonBody(g.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ResourceGroupId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      PatchResourceGroupRequest r;
      r.tenantId = tenantId;
      r.connectionId = connectionId;
      r.resourceGroupId = id;
      r.labels = jsonPairArray(j, "labels");

      auto result = usecase.patchResourceGroup(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Resource group updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ResourceGroupId(extractIdFromPath(req.requestURI.to!string));
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      auto result = usecase.deleteResourceGroup(tenantId, connectionId, id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
