/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.dashboard;
// import uim.platform.logging.application.usecases.manage.dashboards;
// import uim.platform.logging.application.dto;
// import uim.platform.logging.domain.entities.dashboard;


import uim.platform.logging;

mixin(ShowModule!());

@safe:

class DashboardController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
        CreateDashboardRequest r;
    r.tenantId = precheck.tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.isDefault = data.getBoolean("isDefault");
    r.createdBy = UserId(data.getString("createdBy"));

    foreach (pj; data.getArray("panels")) {
      PanelDTO p;
      p.panelId = PanelId(pj.getString("id"));
      p.title = pj.getString("title");
      p.panelType = pj.getString("panelType");
      p.query = pj.getString("query");
      p.positionX = pj.getInteger("positionX");
      p.positionY = pj.getInteger("positionY");
      p.width = pj.getInteger("width");
      p.height = pj.getInteger("height");
      r.panels ~= p;
    }

    auto result = usecase.createDashboard(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Dashboard created successfully", "Created", 201, resp);
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
      .set("totalCount", dashboards.length);

    return successResponse("Dashboards retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DashboardId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid dashboard ID", 400);

    auto d = usecase.getDashboard(tenantId, id);
    if (d.isNull)
      return errorResponse("Dashboard not found", 404); 

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

    return successResponse("Dashboard retrieved successfully", "Retrieved", 200, dj);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DashboardId(precheck.id);
    auto data = precheck.data;
    UpdateDashboardRequest r;
    r.tenantId = precheck.tenantId;
    r.dashboardId = id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.isDefault = data.getBoolean("isDefault");

    auto result = usecase.updateDashboard(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Dashboard updated successfully", "Updated", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DashboardId(precheck.id);

    usecase.deleteDashboard(tenantId, id);
    auto resp = Json.emptyObject
      .set("id", id);

    return successResponse("Dashboard deleted successfully", "Deleted", 200, resp);
  }
}
