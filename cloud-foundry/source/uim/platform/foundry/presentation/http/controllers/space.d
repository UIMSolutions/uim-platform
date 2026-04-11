/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.space;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.foundry.application.usecases.manage.spaces;
import uim.platform.foundry.application.dto;
import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.space;

class SpaceController : PlatformController {
  private ManageSpacesUseCase useCase;

  this(ManageSpacesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/spaces", &handleCreate);
    router.get("/api/v1/spaces", &handleList);
    router.get("/api/v1/spaces/*", &handleGetById);
    router.put("/api/v1/spaces/*", &handleUpdate);
    router.delete_("/api/v1/spaces/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateSpaceRequest();
      r.tenantId = req.getTenantId;
      r.orgId = j.getString("orgId");
      r.name = j.getString("name");
      r.allowSsh = j.getBoolean("allowSsh", true);
      r.createdBy = j.getString("createdBy");

      auto result = useCase.createSpace(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto spaces = useCase.listSpaces(tenantId);

      auto arr = Json.emptyArray;
      foreach (s; spaces)
        arr ~= serializeSpace(s);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(spaces.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto space = useCase.getSpace(tenantId, id);
      if (space is null) {
        writeError(res, 404, "Space not found");
        return;
      }
      res.writeJsonBody(serializeSpace(*space), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateSpaceRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.allowSsh = j.getBoolean("allowSsh", true);

      auto result = useCase.updateSpace(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.deleteSpace(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeSpace(const Space s) {
    return Json.emptyObject
      .set("id", s.id)
      .set("orgId", s.orgId)
      .set("tenantId", s.tenantId)
      .set("name", s.name)
      .set("status", s.status.to!string)
      .set("allowSsh", s.allowSsh)
      .set("createdBy", s.createdBy)
      .set("createdAt", s.createdAt)
      .set("updatedAt", s.updatedAt);
  }
}
