/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task_action;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskActionController : SAPController {
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
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Action recorded");
                res.writeJsonBody(resp, 201);
            } ) {
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
            } ) {
                actions = [];
            }

            auto jarr = Json.emptyArray;
            foreach (ref a; actions) {
                jarr ~= actionToJson(a);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) actions.length);
            resp["resources"] = jarr;
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
            auto a = uc.get_(tenantId, id);
            if (a.id.isEmpty) {
                writeError(res, 404, "Action not found");
                return;
            }
            res.writeJsonBody(actionToJson(a), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            TenantId tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Action deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json actionToJson(ref TaskAction a) {
        import std.conv : to;
        auto j = Json.emptyObject;
        j["id"] = Json(a.id);
        j["tenantId"] = Json(a.tenantId);
        j["taskId"] = Json(a.taskId);
        j["actionType"] = Json(a.actionType.to!string);
        j["performedBy"] = Json(a.performedBy);
        j["forwardTo"] = Json(a.forwardTo);
        j["comment"] = Json(a.comment);
        j["performedAt"] = Json(a.performedAt);
        return j;
    }
}
