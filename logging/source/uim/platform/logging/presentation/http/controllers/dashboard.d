/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.dashboard;

import uim.platform.logging.application.usecases.manage.dashboards;
import uim.platform.logging.application.dto;
import uim.platform.logging.domain.entities.dashboard;
import uim.platform.logging.domain.types;
import uim.platform.logging.presentation.http.json_utils;

import uim.platform.logging;

class DashboardController : PlatformController {
  private ManageDashboardsUseCase uc;

  this(ManageDashboardsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/dashboards", &handleCreate);
    router.get("/api/v1/dashboards", &handleList);
    router.get("/api/v1/dashboards/*", &handleGet);
    router.put("/api/v1/dashboards/*", &handleUpdate);
    router.delete_("/api/v1/dashboards/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDashboardRequest r;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.isDefault = j.getBoolean("isDefault");
      r.createdBy = j.getString("createdBy");

      auto panelsVal = "panels" in j;
      if (panelsVal !is null && (*panelsVal).type == Json.Type.array) {
        foreach (pj; *panelsVal) {
          PanelDTO p;
          p.id = getString(pj, "id");
          p.title = getString(pj, "title");
          p.panelType = getString(pj, "panelType");
          p.query = getString(pj, "query");
          p.positionX = jsonInt(pj, "positionX");
          p.positionY = jsonInt(pj, "positionY");
          p.width = jsonInt(pj, "width");
          p.height = jsonInt(pj, "height");
          r.panels ~= p;
        }
      }

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto dashboards = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (d; dashboards) {
        auto dj = Json.emptyObject;
        dj["id"] = Json(d.id);
        dj["name"] = Json(d.name);
        dj["description"] = Json(d.description);
        dj["isDefault"] = Json(d.isDefault);
        dj["panelCount"] = Json(d.panels.length);
        jarr ~= dj;
      }

      auto resp = Json.emptyObject;
      resp["items"] = jarr;
      resp["totalCount"] = Json(dashboards.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto d = uc.get_(id);

      if (d.id.isEmpty) {
        writeError(res, 404, "Dashboard not found");
        return;
      }

      auto dj = Json.emptyObject;
      dj["id"] = Json(d.id);
      dj["name"] = Json(d.name);
      dj["description"] = Json(d.description);
      dj["isDefault"] = Json(d.isDefault);

      auto parr = Json.emptyArray;
      foreach (p; d.panels) {
        parr ~= Json.emptyObject
        .set("id", p.id)
        .set("title", p.title)
        .set("query", p.query)
        .set("positionX", p.positionX)
        .set("positionY", p.positionY)
        .set("width", p.width)
        .set("height", p.height);
      }
      dj["panels"] = parr;

      res.writeJsonBody(dj, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      UpdateDashboardRequest r;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.isDefault = j.getBoolean("isDefault");

      auto result = uc.update(id, r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      uc.remove(id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
