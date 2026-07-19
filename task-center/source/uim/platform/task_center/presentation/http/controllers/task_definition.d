/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task_definition;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskDefinitionController : ManageHttpController {
    private ManageTaskDefinitionsUseCase usecase;

    this(ManageTaskDefinitionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/task-center/definitions", &handleList);
        router.get("/api/v1/task-center/definitions/*", &handleGet);
        router.post("/api/v1/task-center/definitions", &handleCreate);
        router.put("/api/v1/task-center/definitions/*", &handleUpdate);
        router.post("/api/v1/task-center/definitions/*/activate", &handleActivate);
        router.post("/api/v1/task-center/definitions/*/deactivate", &handleDeactivate);
        router.delete_("/api/v1/task-center/definitions/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateTaskDefinitionRequest r;
        r.tenantId = tenantId;
        r.definitionId = precheck.id;
        r.providerId = data.getString("providerId");
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.category = data.getString("category");
        r.taskSchema = data.getString("taskSchema");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createDefinition(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Task definition created successfully", "Created", 201, responseData);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto providerId = TaskProviderId(precheck.query.get("providerId", ""));

        TaskDefinition[] defs = providerId.isNull
            ? usecase.listDefinitions(tenantId) 
            : usecase.listDefinitions(tenantId, providerId);
        auto list = defs.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Task definitions retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        import std.algorithm : endsWith;

        auto path = precheck.path;
        if (path.endsWith("/activate") || path.endsWith("/deactivate"))
            return errorResponse("Invalid path for get operation", 400);

        auto id = TaskDefinitionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid task definition ID", 400);

        auto d = usecase.getDefinition(tenantId, id);
        if (d.isNull)
            return errorResponse("Task definition not found", 404);

        auto response = d.toJson();
        return successResponse("Task definition retrieved successfully", 200, response);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TaskDefinitionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid task definition ID", 400);

        auto data = precheck.data;
        UpdateTaskDefinitionRequest r;
        r.tenantId = tenantId;
        r.definitionId = id;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.category = data.getString("category");
        r.taskSchema = data.getString("taskSchema");
        r.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateDefinition(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Task definition updated");

        return successResponse("Task definition updated successfully", "Updated", 200, resp);
    }

    protected Json activateHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto path = precheck.path;
        auto stripped = path[0 .. $ - 9]; // remove "/activate"
        auto id = TaskDefinitionId(extractIdFromPath(stripped));
        if (id.isNull)
            return errorResponse("Invalid task definition ID", 400);

        auto result = usecase.activateDefinition(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Task definition activated");

        return successResponse("Task definition activated successfully", "Activated", 200, resp);
    }

    mixin(HandleTemplate!("handleActivate", "activateHandler"));

    protected Json deactivateHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto path = precheck.path;
        auto stripped = path[0 .. $ - 11]; // remove "/deactivate"
        auto id = TaskDefinitionId(extractIdFromPath(stripped));
        if (id.isNull)
            return errorResponse("Invalid task definition ID", 400);

        auto result = usecase.deactivateDefinition(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Task definition deactivated");

        return successResponse("Task definition deactivated successfully", "Deactivated", 200, resp);
    }

    mixin(HandleTemplate!("handleDeactivate", "deactivateHandler"));

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TaskDefinitionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid task definition ID", 400);

        auto result = usecase.deleteDefinition(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
            
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Task definition deleted successfully", "Deleted", 200, resp);
    }
}