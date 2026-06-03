/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.presentation.http.controllers.screen_set;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class ScreenSetController : ManageController {
    private ManageScreenSetsUseCase screenSets;

    this(ManageScreenSetsUseCase screenSets) {
        this.screenSets = screenSets;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/customer-identity/screen-sets", &handleList);
        router.get("/api/v1/customer-identity/screen-sets/*", &handleGet);
        router.post("/api/v1/customer-identity/screen-sets", &handleCreate);
        router.put("/api/v1/customer-identity/screen-sets/*", &handleUpdate);
        router.delete_("/api/v1/customer-identity/screen-sets/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = screenSets.listScreenSets(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Screen sets retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        ScreenSetDTO dto;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.flowType = data.getString("flowType");
        dto.htmlContent = data.getString("htmlContent");
        dto.cssContent = data.getString("cssContent");
        dto.jsContent = data.getString("jsContent");
        dto.locale = data.getString("locale");
        dto.version_ = data.getString("version");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = screenSets.createScreenSet(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Screen set created successfully", "Created", 201, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = ScreenSetId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Screen Set ID").set("status", "error").set("statusCode", 400);

        auto e = screenSets.getScreenSet(tenantId, id);
        if (e.isNull)
            return errorResponse("Screen set not found", 404);

        return successResponse("Screen set retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = ScreenSetId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Screen Set ID").set("status", "error").set("statusCode", 400);

        auto data = precheck.data;
        ScreenSetDTO dto;
        dto.screenSetId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.htmlContent = data.getString("htmlContent");
        dto.cssContent = data.getString("cssContent");
        dto.jsContent = data.getString("jsContent");
        dto.locale = data.getString("locale");
        dto.version_ = data.getString("version");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = screenSets.updateScreenSet(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Screen set updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = ScreenSetId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Screen Set ID").set("status", "error").set("statusCode", 400);

        auto result = screenSets.deleteScreenSet(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Screen set deleted successfully", "Deleted", 200, responseData);
    }
}
