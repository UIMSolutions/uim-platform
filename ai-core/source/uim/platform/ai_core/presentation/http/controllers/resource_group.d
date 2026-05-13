/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.resource_group;

// import uim.platform.ai_core.application.usecases.manage.resource_groups;
// import uim.platform.ai_core.application.dto;

// import uim.platform.ai_core;
import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
class ResourceGroupController : PlatformController {
  private ManageResourceGroupsUseCase groups;

  this(ManageResourceGroupsUseCase groups) {
    this.groups = groups;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v2/admin/resourceGroups", &handleCreate);
    router.get("/api/v2/admin/resourceGroups", &handleList);
    router.get("/api/v2/admin/resourceGroups/*", &handleGet);
    router.patch_("/api/v2/admin/resourceGroups/*", &handlePatch);
    router.delete_("/api/v2/admin/resourceGroups/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateResourceGroupRequest r;
      r.tenantId = tenantId;
      r.resourceGroupId = j.getString("resourceGroupId");
      r.labels = jsonKeyValuePairs(j, "labels");

      auto result = groups.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("resourceGroupId", result.id)
          .set("message", "Resource group created");

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
      auto tenantId = req.getTenantId();
      auto groups = groups.listResourceGroups(tenantId);

      auto jarr = Json.emptyArray;
      foreach (rg; groups) {
        auto lArr = Json.emptyArray;
        foreach (lbl; rg.labels) {
          lArr ~= Json.emptyObject
            .set("key", lbl.key)
            .set("value", lbl.value);
        }

        jarr ~= Json.emptyObject
          .set("resourceGroupId", rg.id)
          .set("tenantId", rg.tenantId)
          .set("status", rg.status)
          .set("createdAt", rg.createdAt)
          .set("labels", lArr);
      }

      auto resp = Json.emptyObject
        .set("count", groups.length)
        .set("resources", jarr)
        .set("message", "Resource groups retrieved successfully");
      
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId();
      auto id = ResourceGroupId(extractIdFromPath(req.requestURI.to!string));

      auto rg = groups.getResourceGroup(id);
      if (rg.isNull) {
        writeError(res, 404, "Resource group not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("resourceGroupId", rg.id)
        .set("tenantId", rg.tenantId)
        .set("status", rg.status)
        .set("createdAt", rg.createdAt)
        .set("message", "Resource group retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetPatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ResourceGroupId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;
      PatchResourceGroupRequest r;
      r.tenantId = tenantId;
      r.resourceGroupId = id;
      r.labels = jsonKeyValuePairs(j, "labels");

      auto result = groups.patchResourceGroup(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("resourceGroupId", result.id)
          .set("message", "Resource group updated");
        
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ResourceGroupId(extractIdFromPath(req.requestURI.to!string));

      auto result = groups.deleteResourceGroup(id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
