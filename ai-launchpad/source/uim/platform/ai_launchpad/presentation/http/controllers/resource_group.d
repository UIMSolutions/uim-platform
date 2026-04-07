/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.resource_group;

import uim.platform.ai_launchpad.application.usecases.manage.resource_groups;
import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

class ResourceGroupController : SAPController {
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
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Resource group created");
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

      typeof(uc.listAll()) groups;
      if (connectionId.length > 0)
        groups = uc.listByConnection(connectionId);
      else
        groups = uc.listAll();

      auto jarr = Json.emptyArray;
      foreach (ref g; groups) {
        jarr ~= serializeResourceGroup(g);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) groups.length);
      resp["resources"] = jarr;
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

      auto g = uc.get_(id, connectionId);
      if (g.id.length == 0) {
        writeError(res, 404, "Resource group not found");
        return;
      }

      res.writeJsonBody(serializeResourceGroup(g), 200);
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
        auto resp = Json.emptyObject;
        resp["message"] = Json("Resource group updated");
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
    import uim.platform.ai_launchpad.domain.entities.resource_group : LabelPair;
    auto j = Json.emptyObject;
    j["id"] = Json(g.id);
    j["connectionId"] = Json(g.connectionId);

    auto labels = Json.emptyArray;
    foreach (ref l; g.labels) {
      auto lj = Json.emptyObject;
      lj["key"] = Json(l.key);
      lj["value"] = Json(l.value);
      labels ~= lj;
    }
    j["labels"] = labels;

    j["status"] = Json(g.status);
    j["createdAt"] = Json(g.createdAt);
    j["modifiedAt"] = Json(g.modifiedAt);
    return j;
  }
}
