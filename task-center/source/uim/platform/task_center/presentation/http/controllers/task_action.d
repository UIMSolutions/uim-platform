/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task_action;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskActionController : ManageController {
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

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            PerformTaskActionRequest r;
            r.tenantId = tenantId;
            r.taskActionId = TaskActionId(precheck.id);
            r.taskId = TaskId(data.getString("taskId"));
            r.actionType = data.getString("actionType");
            r.performedBy = UserId(data.getString("performedBy"));
            r.forwardTo = UserId(data.getString("forwardTo"));
            r.comment = data.getString("comment");

            auto result = usecase.create(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Action recorded");

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

            auto params = req.queryParams();
            auto taskId = TaskId(params.get("taskId", ""));

            TaskAction[] actions = !taskId.isEmpty
                ? usecase.listTaskActions(tenantId, taskId)
                : null;

            auto jarr = actions.map!(a => a.toJson()).array.toJson;

            auto resp = Json.emptyObject
                .set("count", actions.length)
                .set("resources", jarr)
                .set("message", "Action list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = TaskActionprecheck.id);
            auto a = usecase.getById(tenantId, id);
            if (a.isNull) {
                writeError(res, 404, "Action not found");
                return;
            }
            res.writeJsonBody(toJson(a), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = TaskActionprecheck.id);
            auto result = usecase.deleteTaskAction(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Action deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

}
