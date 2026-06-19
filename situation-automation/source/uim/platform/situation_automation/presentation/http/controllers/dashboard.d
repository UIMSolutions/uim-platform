/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.dashboard;
// import uim.platform.situation_automation.application.usecases.manage.dashboards;
// import uim.platform.situation_automation.application.dto;

import uim.platform.situation_automation;

// mixin(ShowModule!());

@safe:

class DashboardController : ManageHttpController {
    private ManageDashboardsUseCase usecase;

    this(ManageDashboardsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/situation-automation/dashboards", &handleList);
        router.get("/api/v1/situation-automation/dashboards/*", &handleGet);
        router.post("/api/v1/situation-automation/dashboards", &handleCreate);
        router.put("/api/v1/situation-automation/dashboards/*", &handleUpdate);
        router.delete_("/api/v1/situation-automation/dashboards/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateDashboardRequest r;
        r.tenantId = tenantId;
        r.dashboardId = DashboardId(precheck.id);
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.type = data.getString("type");
        r.refreshIntervalSeconds = data.getInteger("refreshIntervalSeconds");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createDashboard(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Dashboard created");

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
                .set("type", d.type.to!string)
                .set("refreshIntervalSeconds", d.refreshIntervalSeconds)
                .set("createdAt", d.createdAt);
        }

        auto resp = Json.emptyObject
            .set("count", Json(dashboards.length))
            .set("resources", jarr)
            .set("message", "Dashboards retrieved");

        return successResponse("Dashboards retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DashboardId(precheck.id);
        auto d = usecase.getDashboard(tenantId, id);
        if (d.isNull) {
            writeError(res, 404, "Dashboard not found");
            return;
        }

        auto resp = Json.emptyObject
            .set("id", d.id)
            .set("name", d.name)
            .set("description", d.description)
            .set("type", d.type.to!string)
            .set("refreshIntervalSeconds", d.refreshIntervalSeconds)
            .set("createdBy", d.createdBy)
            .set("updatedBy", d.updatedBy)
            .set("createdAt", d.createdAt)
            .set("updatedAt", d.updatedAt);

        return successResponse("Dashboard retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DashboardId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid dashboard ID", 400);

        auto data = precheck.data;
        UpdateDashboardRequest r;
        r.tenantId = tenantId;
        r.dashboardId = id;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.refreshIntervalSeconds = data.getInteger("refreshIntervalSeconds");
        r.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateDashboard(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);

        return successResponse("Dashboard updated successfully", "Updated", 200, resp);
    }
}

override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DashboardId(precheck.id);
    if (id.isNull)
        return errorResponse("Invalid dashboard ID", 400);

    auto result = usecase.deleteDashboard(tenantId, id);
    if (result.hasError)
        return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
        .set("id", result.id)
        .set("message", "Dashboard deleted");

    return successResponse("Dashboard deleted successfully", "Deleted", 200, resp);
}
}
