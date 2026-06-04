/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.user_task_filter;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class UserTaskFilterController : ManageHttpController {
    private ManageUserTaskFiltersUseCase usecase;

    this(ManageUserTaskFiltersUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/task-center/filters", &handleList);
        router.get("/api/v1/task-center/filters/*", &handleGet);
        router.post("/api/v1/task-center/filters", &handleCreate);
        router.put("/api/v1/task-center/filters/*", &handleUpdate);
        router.post("/api/v1/task-center/filters/*/default", &handleSetDefault);
        router.delete_("/api/v1/task-center/filters/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateUserTaskFilterRequest r;
        r.tenantId = precheck.tenantId;
        r.id = precheck.id;
        r.userId = data.getString("userId");
        r.name = data.getString("name");
        r.description = data.getString("description");

        auto result = usecase.create(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Filter created successfully", "Created", 201, responseData);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto params = req.queryParams();
        auto userId = params.get("userId", "");

        UserTaskFilter[] filters = !userId.isEmpty
            ? usecase.listUserTaskFilters(tenantId, userId) : [];

        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Filter list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        if (path.endsWith("/default"))
            return errorResponse("Use the /default endpoint to get the default filter", 400);

        auto id = UserTaskFilterId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid filter ID", 400);

        auto f = usecase.getUserTaskFilter(tenantId, id);
        if (f.isNull)
            return errorResponse("Scan job not found", 404);

        auto responseData = f.toJson();
        return successResponse("Filter retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = UserTaskFilterId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid filter ID", 400);

        auto data = precheck.data;
        UpdateUserTaskFilterRequest r;
        r.tenantId = precheck.tenantId;
        r.userTaskFilterId = id;
        r.name = data.getString("name");
        r.description = data.getString("description");

        auto result = usecase.update(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Filter updated successfully", "Updated", 200, responseData);
    }

    protected Json setDefaultHandler(HTTPServerRequest req) {
        auto precheck = super.ostHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto stripped = path[0 .. $ - 8]; // remove "/default"
        auto id = UserTaskFilterId(extractIdFromPath(stripped));
        if (id.isNull)
            return errorResponse("Invalid filter ID", 400);

        auto result = usecase.setDefaultUserTaskFilter(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Filter set as default successfully", "Updated", 200, responseData);
    }

    protected void handleSetDefault(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = setDefaultHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = UserTaskFilterId(precheck.id);
        auto result = usecase.deleteUserTaskFilter(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Filter deleted successfully", "Deleted", 200, responseData);
    }
}
