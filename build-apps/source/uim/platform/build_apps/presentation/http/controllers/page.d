/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.page;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class PageController : ManageHttpController {
    private ManagePagesUseCase usecase;

    this(ManagePagesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/build-apps/pages", &handleList);
        router.get("/api/v1/build-apps/pages/*", &handleGet);
        router.post("/api/v1/build-apps/pages", &handleCreate);
        router.put("/api/v1/build-apps/pages/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/pages/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listPages(tenantId);
           auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Page list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = PageId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid page ID", 400);

        auto page = usecase.getPage(tenantId, id);
        if (page.isNull)
            return errorResponse("Page not found", 404);

        auto responseData = page.toJson();
        return successResponse("Page retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        PageDTO dto;
        dto.pageId = PageId(precheck.id);
        dto.tenantId = precheck.tenantId;
        dto.applicationId = ApplicationId(data.getString("applicationId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.pageType = data.getString("pageType");
        dto.route = data.getString("route");
        dto.layoutConfig = data.getString("layoutConfig");
        dto.componentTree = data.getString("componentTree");
        dto.styleOverrides = data.getString("styleOverrides");
        dto.pageVariables = data.getString("pageVariables");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createPage(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Page created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        PageDTO dto;
        dto.pageId = PageId(precheck.id);
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.route = data.getString("route");
        dto.layoutConfig = data.getString("layoutConfig");
        dto.componentTree = data.getString("componentTree");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updatePage(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Page updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = PageId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid page ID", 400);

        auto result = usecase.deletePage(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Page deleted successfully", "Deleted", 200, responseData);
    }
}
