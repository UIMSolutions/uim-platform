/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.workspace;

import uim.platform.ai_launchpad.application.usecases.manage.workspaces;
import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

class WorkspaceController : PlatformController {
  private ManageWorkspacesUseCase uc;

  this(ManageWorkspacesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/workspaces", &handleCreate);
    router.get("/api/v1/workspaces", &handleList);
    router.get("/api/v1/workspaces/*", &handleGet);
    router.patch("/api/v1/workspaces/*", &handlePatch);
    router.delete_("/api/v1/workspaces/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateWorkspaceRequest r;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Workspace created");
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

      typeof(uc.listAll()) workspaces;
      if (tenantId.length > 0)
        workspaces = uc.listByTenant(tenantId);
      else
        workspaces = uc.listAll();

      auto jarr = Json.emptyArray;
      foreach (w; workspaces) {
        jarr ~= serializeWorkspace(w);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(workspaces.length);
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

      auto w = uc.get_(id);
      if (w.id.isEmpty) {
        writeError(res, 404, "Workspace not found");
        return;
      }

      res.writeJsonBody(serializeWorkspace(w), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;

      PatchWorkspaceRequest r;
      r.workspaceId = id;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["message"] = Json("Workspace updated");
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

      auto result = uc.remove(id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeWorkspace(Workspace w) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(w.id);
    j["name"] = Json(w.name);
    j["description"] = Json(w.description);
    j["tenantId"] = Json(w.tenantId);
    j["status"] = Json(w.status.to!string);
    j["connectionCount"] = Json(w.connectionCount);
    j["createdAt"] = Json(w.createdAt);
    j["modifiedAt"] = Json(w.modifiedAt);
    return j;
  }
}
