/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task_action;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskActionController : PlatformController {
    private ManageTaskActionsUseCase uc;

    this(ManageTaskActionsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/task-center/actions", &handleList);
        router.get("/api/v1/task-center/actions/*", &handleGet);
        router.post("/api/v1/task-center/actions", &handleCreate);
        router.delete_("/api/v1/task-center/actions/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            PerformTaskActionRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.taskId = j.getString("taskId");
            r.actionType = j.getString("actionType");
            r.performedBy = j.getString("performedBy");
            r.forwardTo = j.getString("forwardTo");
            r.comment = j.getString("comment");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Action recorded");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            TenantId tenantId = req.getTenantId;
            auto params = req.queryParams();
            auto taskId = params.get("taskId", "");

            TaskAction[] actions;
            if (taskId.length > 0) {
                actions = uc.listByTask(tenantId, taskId);
            } else {
                actions = [];
            }

            auto jarr = Json.emptyArray;
            foreach (a; actions) {
                jarr ~= actionToJson(a);
            }

            auto resp = Json.emptyObject
                .set("count", actions.length)
                .set("resources", jarr)
                .set("message", "Action list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            TenantId tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto a = uc.getById(tenantId, id);
            if (a.isNull) {
                writeError(res, 404, "Action not found");
                return;
            }
            res.writeJsonBody(toJson(a), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            TenantId tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.removeById(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Action deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json actionToJson(TaskAction a) {
        return Json.emptyObject
            .set("id", a.id)
            .set("tenantId", a.tenantId)
            .set("taskId", a.taskId)
            .set("actionType", a.actionType.to!string)
            .set("performedBy", a.performedBy)
            .set("forwardTo", a.forwardTo)
            .set("comment", a.comment)
            .set("performedAt", a.performedAt);
    }
}
