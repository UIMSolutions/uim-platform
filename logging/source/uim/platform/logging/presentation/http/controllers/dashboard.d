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

class DashboardController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateDashboardRequest r;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.isDefault = data.getBoolean("isDefault");
      r.createdBy = UserId(data.getString("createdBy"));

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
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Dashboard created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = DashboardId(precheck.id);

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

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = DashboardId(precheck.id);
      auto data = precheck.data;
      UpdateDashboardRequest r;
      r.tenantId = tenantId;
      r.dashboardId = id;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.isDefault = data.getBoolean("isDefault");

      auto result = usecase.updateDashboard(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Dashboard updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = DashboardId(precheck.id);

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
