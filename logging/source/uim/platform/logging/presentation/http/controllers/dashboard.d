/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.dashboard;
// import uim.platform.logging.application.usecases.manage.dashboards;
// import uim.platform.logging.application.dto;
// import uim.platform.logging.domain.entities.dashboard;
// import uim.platform.logging.domain.types;

import uim.platform.logging;

mixin(ShowModule!());

@safe:

class DashboardController : PlatformController {
  private ManageDashboardsUseCase usecase;

  this(ManageDashboardsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/dashboards", &handleCreate);
    router.get("/api/v1/dashboards", &handleList);
    router.get("/api/v1/dashboards/*", &handleGet);
    router.put("/api/v1/dashboards/*", &handleUpdate);
    router.delete_("/api/v1/dashboards/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateDashboardRequest r;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.isDefault = j.getBoolean("isDefault");
      r.createdBy = UserId(j.getString("createdBy"));

      foreach (pj; j.getArray("panels")) {
        PanelDTO p;
        p.panelId = PanelId(getString(pj, "id"));
        p.title = getString(pj, "title");
        p.panelType = getString(pj, "panelType");
        p.query = getString(pj, "query");
        p.positionX = jsonInt(pj, "positionX");
        p.positionY = jsonInt(pj, "positionY");
        p.width = jsonInt(pj, "width");
        p.height = jsonInt(pj, "height");
        r.panels ~= p;
      }

      auto result = usecase.createDashboard(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Dashboard created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto dashboards = usecase.listDashboards(tenantId);

      auto jarr = Json.emptyArray;
      foreach (d; dashboards) {
        jarr ~= Json.emptyObject
          .set("id", d.id)
          .set("name", d.name)
          .set("description", d.description)
          .set("isDefault", d.isDefault)
          .set("panelCount", d.panels.length);
      }

      auto resp = Json.emptyObject
        .set("items", jarr)
        .set("totalCount", dashboards.length)
        .set("message", "Dashboards retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = DashboardId(extractIdFromPath(req.requestURI.to!string));

      auto d = usecase.getDashboard(tenantId, id);
      if (d.isNull) {
        writeError(res, 404, "Dashboard not found");
        return;
      }

      auto dj = Json.emptyObject
        .set("id", d.id)
        .set("name", d.name)
        .set("description", d.description)
        .set("isDefault", d.isDefault);

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

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = DashboardId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;

      UpdateDashboardRequest r;
      r.tenantId = tenantId;
      r.dashboardId = id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.isDefault = j.getBoolean("isDefault");

      auto result = usecase.updateDashboard(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Dashboard updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = DashboardId(extractIdFromPath(req.requestURI.to!string));

      usecase.deleteDashboard(tenantId, id);
      auto resp = Json.emptyObject
        .set("id", id)
        .set("message", "Dashboard deleted successfully");
        
      res.writeJsonBody(resp, 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
