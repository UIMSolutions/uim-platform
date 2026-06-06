/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.visibility;
// import uim.platform.process_automation.application.visibilitiess.manage.visibilities;
// import uim.platform.process_automation.application.dto;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:

class VisibilityController : ManageHttpController {
    private ManageVisibilitiesUseCase visibilityUsecase;

    this(ManageVisibilitiesUseCase visibilityUsecase) {
        this.visibilityUsecase = visibilityUsecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/process-automation/visibility", &handleList);
        router.get("/api/v1/process-automation/visibility/*", &handleGet);
        router.post("/api/v1/process-automation/visibility", &handleCreate);
        router.put("/api/v1/process-automation/visibility/*", &handleUpdate);
        router.delete_("/api/v1/process-automation/visibility/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateVisibilityRequest r;
        r.tenantId = tenantId;
        r.visibilityId = VisibilityId(precheck.id);
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.dashboardType = data.getString("dashboardType");
        r.processIds = data.getStrings("processIds");
        r.refreshIntervalSeconds = data.getString("refreshIntervalSeconds");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = visibilityUsecase.createVisibility(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Visibility dashboard created successfully", "Created", 201, responseData);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = visibilityUsecase.listVisibilities(tenantId);
        auto jarr = Json.emptyArray;
        foreach (v; items) {
            jarr ~= Json.emptyObject
                .set("id", v.id)
                .set("name", v.name)
                .set("description", v.description)
                .set("status", v.status.to!string)
                .set("dashboardType", v.dashboardType.to!string)
                .set("createdAt", v.createdAt)
                .set("updatedAt", v.updatedAt);
        }

        auto responseData = Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr);
        return successResponse("Visibility dashboard list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = VisibilityId(precheck.id);
        auto v = visibilityUsecase.getVisibility(tenantId, id);
        if (v.isNull)
            return errorResponse("Visibility dashboard not found", 404);

        auto resp = Json.emptyObject
            .set("id", v.id)
            .set("name", v.name)
            .set("description", v.description)
            .set("status", v.status.to!string)
            .set("dashboardType", v.dashboardType.to!string)
            .set("processIds", v.processIds.map!(pid => Json(pid.value))
                    .array.toJson)
            .set("refreshIntervalSeconds", Json(v.refreshIntervalSeconds))
            .set("createdBy", Json(v.createdBy.value))
            .set("updatedBy", Json(v.updatedBy.value))
            .set("createdAt", Json(v.createdAt))
            .set("updatedAt", Json(v.updatedAt));

        return successResponse("Visibility dashboard retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        UpdateVisibilityRequest r;
        r.tenantId = tenantId;
        r.visibilityId = VisibilityId(precheck.id);
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.refreshIntervalSeconds = data.getString("refreshIntervalSeconds");
        r.updatedBy = UserId(data.getString("updatedBy"));

        auto result = visibilityUsecase.updateVisibility(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Visibility dashboard updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto tenantId = precheck.tenantId;

        auto id = VisibilityId(precheck.id);
        auto result = visibilityUsecase.deleteVisibility(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Visibility dashboard deleted successfully", 200, responseData);
    }
}
