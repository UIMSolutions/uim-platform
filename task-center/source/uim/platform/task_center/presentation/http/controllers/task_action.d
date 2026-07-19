/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task_action;

import uim.platform.task_center;
mixin(ShowModule!());

@safe:

class TaskActionController : ManageHttpController {
    private ManageTaskActionsUseCase usecase;

    this(ManageTaskActionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/task-center/actions", &handleList);
        router.get("/api/v1/task-center/actions/*", &handleGet);
        router.post("/api/v1/task-center/actions", &handleCreate);
        router.delete_("/api/v1/task-center/actions/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        PerformTaskActionRequest r;
        r.tenantId = tenantId;
        r.actionId = TaskActionId(precheck.id);
        r.taskId = TaskId(data.getString("taskId"));
        r.actionType = data.getString("actionType");
        r.performedBy = data.userId("performedBy");
        r.forwardTo = data.getString("forwardTo");
        r.comment = data.getString("comment");

        auto result = usecase.createAction(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Action performed successfully", "Created", 201, resp);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TaskId(precheck.query.get("taskId", ""));
        if (id.isNull)
            return errorResponse("Invalid task ID", 400);

        TaskAction[] actions = usecase.listActions(tenantId, id);
        auto jarr = actions.map!(a => a.toJson()).array.toJson;

        auto resp = Json.emptyObject
            .set("count", actions.length)
            .set("resources", jarr);

        return successResponse("Actions retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TaskActionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid action ID", 400);

        auto a = usecase.getAction(tenantId, id);
        if (a.isNull)
            return errorResponse("Action not found", 404);

        auto response = a.toJson();
        return successResponse("Action retrieved successfully", 200, response);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto actionId = TaskActionId(precheck.id);
        if (actionId.isNull)
            return errorResponse("Invalid action ID", 400);

        auto result = usecase.deleteAction(tenantId, actionId);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Action deleted successfully", "Deleted", 200, resp);
    }
}
