/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task_provider;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskProviderController : ManageController {
    private ManageTaskProvidersUseCase usecase;

    this(ManageTaskProvidersUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/task-center/providers", &handleList);
        router.get("/api/v1/task-center/providers/*", &handleGet);
        router.post("/api/v1/task-center/providers", &handleCreate);
        router.put("/api/v1/task-center/providers/*", &handleUpdate);
        router.post("/api/v1/task-center/providers/*/activate", &handleActivate);
        router.post("/api/v1/task-center/providers/*/deactivate", &handleDeactivate);
        router.post("/api/v1/task-center/providers/*/sync", &handleSync);
        router.delete_("/api/v1/task-center/providers/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateTaskProviderRequest r;
        r.tenantId = tenantId;
        r.id = precheck.id;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.providerType = data.getString("providerType");
        r.authType = data.getString("authType");
        r.endpointUrl = data.getString("endpointUrl");
        r.authEndpointUrl = data.getString("authEndpointUrl");
        r.clientId = data.getString("clientId");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.create(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Provider created successfully", "Created", 201, responseData);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto providers = usecase.list(tenantId);
        auto list = providers.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Providers retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto path = precheck.path;
        if (path.endsWith("/activate") || path.endsWith("/deactivate") || path.endsWith(
                "/sync"))
            return errorResponse("Invalid path for get operation", 400);

        auto tenantId = precheck.tenantId;
        auto id = TaskProviderId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid provider ID", 400);

        auto provider = usecase.getById(tenantId, id);
        if (provider.isNull)
            return errorResponse("Provider not found", 404);

        auto responseData = provider.toJson();
        return successResponse("Provider retrieved successfully", "Retrieved", 200, responseData);
    }

    protected Json UpdateHandler(HTTPServerRequest req) {
        auto precheck = super.putHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TaskProviderId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid provider ID", 400);

        auto data = precheck.data;
        UpdateTaskProviderRequest r;
        r.tenantId = tenantId;
        r.id = id;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.endpointUrl = data.getString("endpointUrl");
        r.authEndpointUrl = data.getString("authEndpointUrl");
        r.clientId = data.getString("clientId");

        r.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.update(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Provider updated successfully", "Updated", 200, resp);
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = updateHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected Json activateHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto stripped = path[0 .. $ - 9]; // remove "/activate"

        auto id = TaskProviderId(extractIdFromPath(stripped));
        if (id.isNull)
            return errorResponse("Invalid provider ID", 400);

        auto result = usecase.activate(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Provider activated successfully", "Updated", 200, responseData);
    }

    protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = activateHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected Json deactivateHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto stripped = path[0 .. $ - 11]; // remove "/deactivate"

        auto id = TaskProviderId(extractIdFromPath(stripped));
        if (id.isNull)
            return errorResponse("Invalid provider ID", 400);

        auto result = usecase.deactivate(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Provider deactivated successfully", "Updated", 200, responseData);
    }

    protected void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = deactivateHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected Json syncHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto stripped = path[0 .. $ - 5]; // remove "/sync"

        auto id = TaskProviderId(extractIdFromPath(stripped));
        if (id.isNull)
            return errorResponse("Invalid provider ID", 400);

        auto result = usecase.sync(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Provider sync initiated successfully", "Updated", 200, responseData);
    }

    protected void handleSync(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = syncHandler(req);
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
        auto id = TaskProviderId(precheck.id);
        auto result = usecase.deleteTaskProvider(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Provider deleted successfully", "Deleted", 200, responseData);
    }
}
