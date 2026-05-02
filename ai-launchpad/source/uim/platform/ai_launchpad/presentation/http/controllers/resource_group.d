/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.resource_group;

import uim.platform.ai_launchpad.application.usecases.manage.resource_groups;
import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

class ResourceGroupController : PlatformController {
  private ManageResourceGroupsUseCase uc;

  this(ManageResourceGroupsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/admin/resource-groups", &handleCreate);
    router.get("/api/v1/admin/resource-groups", &handleList);
    router.get("/api/v1/admin/resource-groups/*", &handleGet);
    router.patch("/api/v1/admin/resource-groups/*", &handlePatch);
    router.delete_("/api/v1/admin/resource-groups/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto connectionId = req.headers.get("X-Connection-Id", "");

      CreateResourceGroupRequest r;
      r.connectionId = connectionId;
      r.resourceGroupId = j.getString("resourceGroupId");
      r.labels = jsonPairArray(j, "labels");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Resource group created");

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
      auto connectionId = req.headers.get("X-Connection-Id", "");

      auto groups = connectionId.length > 0
        ? uc.listByConnection(connectionId)
        : uc.listAll();

      auto jarr = groups.map!(g => serializeResourceGroup(g)).array;

      auto resp = Json.emptyObject
        .set("count", groups.length)
        .set("resources", jarr);
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto connectionId = req.headers.get("X-Connection-Id", "");

      auto g = uc.getById(id, connectionId);
      if (g.isNull) {
        writeError(res, 404, "Resource group not found");
        return;
      }

      res.writeJsonBody(g.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      auto connectionId = req.headers.get("X-Connection-Id", "");

      PatchResourceGroupRequest r;
      r.connectionId = connectionId;
      r.resourceGroupId = id;
      r.labels = jsonPairArray(j, "labels");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Resource group updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto connectionId = req.headers.get("X-Connection-Id", "");

      auto result = uc.remove(id, connectionId);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeResourceGroup(ResourceGroup g) {
    auto labels = Json.emptyArray;
    foreach (l; g.labels) {
      labels ~= Json.emptyObject
        .set("key", l.key)
        .set("value", l.value);
    }

    return Json.emptyObject
      .set("id", g.id)
      .set("connectionId", g.connectionId)
      .set("labels", labels)
      .set("status", g.status)
      .set("createdAt", g.createdAt)
      .set("updatedAt", g.updatedAt);
  }
}
