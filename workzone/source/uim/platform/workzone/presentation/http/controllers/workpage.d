/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.workpage;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.workzone.application.usecases.manage.workpages;
import uim.platform.workzone.application.dto;
import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.workpage;
import uim.platform.identity_authentication.presentation.http.json_utils;

class WorkpageController {
  private ManageWorkpagesUseCase useCase;

  this(ManageWorkpagesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/workpages", &handleCreate);
    router.get("/api/v1/workpages", &handleList);
    router.get("/api/v1/workpages/*", &handleGet);
    router.put("/api/v1/workpages/*", &handleUpdate);
    router.delete_("/api/v1/workpages/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateWorkpageRequest();
      r.workspaceId = j.getString("workspaceId");
      r.tenantId = req.getTenantId;
      r.title = j.getString("title");
      r.description = j.getString("description");
      r.sortOrder = j.getInteger("sortOrder");
      r.isDefault = j.getBoolean("isDefault");

      auto result = useCase.createWorkpage(r);
      if (result.isSuccess()) {
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
      auto workspaceId = req.params.get("workspaceId", "");
      auto pages = useCase.listByWorkspace(workspacetenantId, id);
      auto arr = Json.emptyArray;
      foreach (p; pages)
        arr ~= serializePage(p);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) pages.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto page = useCase.getWorkpage(tenantId, id);
      if (page is null) {
        writeError(res, 404, "Page not found");
        return;
      }
      res.writeJsonBody(serializePage(*page), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = UpdateWorkpageRequest();
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.title = j.getString("title");
      r.description = j.getString("description");
      r.sortOrder = j.getInteger("sortOrder");
      r.visible = j.getBoolean("visible", true);

      auto result = useCase.updateWorkpage(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["status"] = Json("updated");
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

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      useCase.deleteWorkpage(tenantId, id);
      res.writeBody("", 204);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

private Json serializePage(Workpage p) {
  auto j = Json.emptyObject;
  j["id"] = Json(p.id);
  j["workspaceId"] = Json(p.workspaceId);
  j["tenantId"] = Json(p.tenantId);
  j["title"] = Json(p.title);
  j["description"] = Json(p.description);
  j["sortOrder"] = Json(p.sortOrder);
  j["visible"] = Json(p.visible);
  j["isDefault"] = Json(p.isDefault);
  j["createdAt"] = Json(p.createdAt);
  j["updatedAt"] = Json(p.updatedAt);
  return j;
}
