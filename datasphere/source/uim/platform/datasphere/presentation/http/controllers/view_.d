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

class ViewController : SAPController {
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
      r.isExposed = jsonBool(j, "isExposed", false);

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("View created");
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
      foreach (ref v; views) {
        auto vj = Json.emptyObject;
        vj["id"] = Json(v.id);
        vj["name"] = Json(v.name);
        vj["description"] = Json(v.description);
        vj["businessName"] = Json(v.businessName);
        vj["isExposed"] = Json(v.isExposed);
        vj["isPersisted"] = Json(v.isPersisted);
        vj["rowCount"] = Json(v.rowCount);
        vj["createdAt"] = Json(v.createdAt);
        jarr ~= vj;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) views.length);
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
      auto spaceId = req.headers.get("X-Space-Id", "");

      auto v = uc.get_(id, spaceId);
      if (v.id.length == 0) {
        writeError(res, 404, "View not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(v.id);
      resp["name"] = Json(v.name);
      resp["description"] = Json(v.description);
      resp["businessName"] = Json(v.businessName);
      resp["sqlExpression"] = Json(v.sqlExpression);
      resp["isExposed"] = Json(v.isExposed);
      resp["isPersisted"] = Json(v.isPersisted);
      resp["rowCount"] = Json(v.rowCount);
      resp["createdAt"] = Json(v.createdAt);
      resp["modifiedAt"] = Json(v.modifiedAt);
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
      r.isExposed = jsonBool(j, "isExposed", false);
      r.isPersisted = jsonBool(j, "isPersisted", false);

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("View updated");
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
