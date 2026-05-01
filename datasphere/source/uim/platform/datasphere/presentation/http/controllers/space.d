/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.space;

import uim.platform.datasphere.application.usecases.manage.spaces;
import uim.platform.datasphere.application.dto;
import uim.platform.datasphere.presentation.http.json_utils;

import uim.platform.datasphere;

class SpaceController : PlatformController {
  private ManageSpacesUseCase uc;

  this(ManageSpacesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/datasphere/spaces", &handleList);
    router.get("/api/v1/datasphere/spaces/*", &handleGet);
    router.post("/api/v1/datasphere/spaces", &handleCreate);
    router.put("/api/v1/datasphere/spaces/*", &handleUpdate);
    router.delete_("/api/v1/datasphere/spaces/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateSpaceRequest r;
      r.tenantId = req.getTenantId;
      r.id = j.getString("id");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.businessName = j.getString("businessName");
      r.priority = j.getInteger("priority", 0);

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", Json("Space created"));

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
      auto spaces = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (s; spaces) {
        jarr ~= Json.emptyObject
          .set("id", s.id)
          .set("name", s.name)
          .set("description", s.description)
          .set("businessName", s.businessName)
          .set("priority", s.priority)
          .set("createdAt", s.createdAt)
          .set("updatedAt", s.updatedAt);
      }

      auto resp = Json.emptyObject
            .set("count", Json(spaces.length))
            .set("resources", jarr)
            .set("message", "Spaces retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto s = uc.getById(id);
      if (s.isNull) {
        writeError(res, 404, "Space not found");
        return;
      }

      auto resp = Json.emptyObject
            .set("id", Json(s.id))
            .set("name", Json(s.name))
            .set("description", Json(s.description))
            .set("businessName", Json(s.businessName))
            .set("priority", Json(s.priority))
            .set("enableAuditLog", Json(s.enableAuditLog))
            .set("createdAt", Json(s.createdAt))
            .set("updatedAt", Json(s.updatedAt))
            .set("message", "Space retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto j = req.json;

      UpdateSpaceRequest r;
      r.tenantId = req.getTenantId;
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.businessName = j.getString("businessName");
      r.priority = j.getInteger("priority", 0);

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", Json("Space updated"));
            
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
}
