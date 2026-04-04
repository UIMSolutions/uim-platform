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

class SpaceController : SAPController {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.id = jsonStr(j, "id");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.businessName = jsonStr(j, "businessName");
      r.priority = jsonInt(j, "priority", 0);

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Space created");
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
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto spaces = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (ref s; spaces) {
        auto sj = Json.emptyObject;
        sj["id"] = Json(s.id);
        sj["name"] = Json(s.name);
        sj["description"] = Json(s.description);
        sj["businessName"] = Json(s.businessName);
        sj["priority"] = Json(cast(long) s.priority);
        sj["createdAt"] = Json(s.createdAt);
        sj["modifiedAt"] = Json(s.modifiedAt);
        jarr ~= sj;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) spaces.length);
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
      auto s = uc.get_(id);
      if (s.id.length == 0) {
        writeError(res, 404, "Space not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(s.id);
      resp["name"] = Json(s.name);
      resp["description"] = Json(s.description);
      resp["businessName"] = Json(s.businessName);
      resp["priority"] = Json(cast(long) s.priority);
      resp["enableAuditLog"] = Json(s.enableAuditLog);
      resp["createdAt"] = Json(s.createdAt);
      resp["modifiedAt"] = Json(s.modifiedAt);
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.businessName = jsonStr(j, "businessName");
      r.priority = jsonInt(j, "priority", 0);

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Space updated");
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
