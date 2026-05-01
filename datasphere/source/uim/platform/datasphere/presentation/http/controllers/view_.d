/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.view_;

import uim.platform.datasphere.application.usecases.manage.views;
import uim.platform.datasphere.application.dto;
import uim.platform.datasphere.presentation.http.json_utils;

import uim.platform.datasphere;

class ViewController : PlatformController {
  private ManageViewsUseCase uc;

  this(ManageViewsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/datasphere/views", &handleList);
    router.get("/api/v1/datasphere/views/*", &handleGet);
    router.post("/api/v1/datasphere/views", &handleCreate);
    router.put("/api/v1/datasphere/views/*", &handleUpdate);
    router.delete_("/api/v1/datasphere/views/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateViewRequest r;
      r.tenantId = req.getTenantId;
      r.spaceId = req.headers.get("X-Space-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.businessName = j.getString("businessName");
      r.semantic = j.getString("semantic");
      r.sqlExpression = j.getString("sqlExpression");
      r.isExposed = j.getBoolean("isExposed", false);

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", Json("View created"));

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
      auto spaceId = req.headers.get("X-Space-Id", "");
      auto views = uc.list(spaceId);

      auto jarr = Json.emptyArray;
      foreach (v; views) {
        jarr ~= Json.emptyObject
          .set("id", v.id)
          .set("name", v.name)
          .set("description", v.description)
          .set("businessName", v.businessName)
          .set("isExposed", v.isExposed)
          .set("isPersisted", v.isPersisted)
          .set("rowCount", v.rowCount)
          .set("createdAt", v.createdAt);
      }

      auto resp = Json.emptyObject
            .set("count", Json(views.length))
            .set("resources", jarr)
            .set("message", "Views retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto spaceId = req.headers.get("X-Space-Id", "");

      auto v = uc.getById(id, spaceId);
      if (v.isNull) {
        writeError(res, 404, "View not found");
        return;
      }

      auto resp = Json.emptyObject
            .set("id", Json(v.id))
            .set("name", Json(v.name))
            .set("description", Json(v.description))
            .set("businessName", Json(v.businessName))
            .set("sqlExpression", Json(v.sqlExpression))
            .set("isExposed", Json(v.isExposed))
            .set("isPersisted", Json(v.isPersisted))
            .set("rowCount", Json(v.rowCount))
            .set("createdAt", Json(v.createdAt))
            .set("updatedAt", Json(v.updatedAt))
            .set("message", "View retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto j = req.json;

      UpdateViewRequest r;
      r.tenantId = req.getTenantId;
      r.spaceId = req.headers.get("X-Space-Id", "");
      r.viewId = extractIdFromPath(req.requestURI.to!string);
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.businessName = j.getString("businessName");
      r.sqlExpression = j.getString("sqlExpression");
      r.isExposed = j.getBoolean("isExposed", false);
      r.isPersisted = j.getBoolean("isPersisted", false);

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", Json("View updated"));
            
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
      auto spaceId = req.headers.get("X-Space-Id", "");

      auto result = uc.remove(id, spaceId);
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
