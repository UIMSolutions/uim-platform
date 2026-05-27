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
class ResourceGroupController : ManageController {
  private ManageResourceGroupsUseCase groups;

  this(ManageResourceGroupsUseCase groups) {
    this.groups = groups;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v2/admin/resourceGroups", &handleCreate);
    router.get("/api/v2/admin/resourceGroups", &handleList);
    router.get("/api/v2/admin/resourceGroups/*", &handleGet);
    router.patch("/api/v2/admin/resourceGroups/*", &handlePatch);
    router.delete_("/api/v2/admin/resourceGroups/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateResourceGroupRequest r;
      r.tenantId = tenantId;
      r.resourceGroupId = data.getString("resourceGroupId");
      r.labels = jsonKeyValuePairs(j, "labels");

      auto result = groups.createResourceGroup(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("resourceGroupId", result.id)
          .set("message", "Resource group created");

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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId();
      auto id = ResourceGroupprecheck.id);

      auto rg = groups.getResourceGroup(tenantId, id);
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

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ResourceGroupprecheck.id);
      auto data = precheck.data;

      PatchResourceGroupRequest r;
      r.tenantId = tenantId;
      r.resourceGroupId = id;
      r.labels = jsonKeyValuePairs(j, "labels");

      auto result = groups.patchResourceGroup(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("resourceGroupId", result.id)
          .set("message", "Resource group updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ResourceGroupprecheck.id);

      auto result = groups.deleteResourceGroup(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
