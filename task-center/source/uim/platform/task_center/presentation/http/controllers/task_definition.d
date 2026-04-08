/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task_definition;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskDefinitionController : SAPController {
    private ManageTaskDefinitionsUseCase uc;

    this(ManageTaskDefinitionsUseCase uc) {
        this.uc = uc;
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

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateTaskDefinitionRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.providerId = j.getString("providerId");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.category = j.getString("category");
            r.taskSchema = j.getString("taskSchema");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Task definition created");
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
            auto providerId = params.get("providerId", "");

            TaskDefinition[] defs;
            if (providerId.length > 0) {
                defs = uc.listByProvider(tenantId, providerId);
            } ) {
                defs = uc.list(tenantId);
            }

            auto jarr = Json.emptyArray;
            foreach (ref d; defs) {
                jarr ~= defToJson(d);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) defs.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            import std.algorithm : endsWith;
            auto path = req.requestURI.to!string;
            if (path.endsWith("/activate") || path.endsWith("/deactivate")) return;

            TenantId tenantId = req.getTenantId;
            auto id = extractIdFromPath(path);
            auto d = uc.get_(tenantId, id);
            if (d.id.length == 0) {
                writeError(res, 404, "Task definition not found");
                return;
            }
            res.writeJsonBody(defToJson(d), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateTaskDefinitionRequest r;
            r.tenantId = req.getTenantId;
            r.id = id;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.category = j.getString("category");
            r.taskSchema = j.getString("taskSchema");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Task definition updated");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 9]; // remove "/activate"
            auto id = extractIdFromPath(stripped);
            TenantId tenantId = req.getTenantId;

            auto result = uc.activate(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Task definition activated");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 11]; // remove "/deactivate"
            auto id = extractIdFromPath(stripped);
            TenantId tenantId = req.getTenantId;

            auto result = uc.deactivate(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Task definition deactivated");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            TenantId tenantId = req.getTenantId;
            auto result = uc.remove(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Task definition deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json defToJson(ref TaskDefinition d) {
        import std.conv : to;
        auto j = Json.emptyObject;
        j["id"] = Json(d.id);
        j["tenantId"] = Json(d.tenantId);
        j["providerId"] = Json(d.providerId);
        j["name"] = Json(d.name);
        j["description"] = Json(d.description);
        j["category"] = Json(d.category.to!string);
        j["taskSchema"] = Json(d.taskSchema);
        j["isActive"] = Json(d.isActive);
        j["requiresClaim"] = Json(d.requiresClaim);
        j["createdBy"] = Json(d.createdBy);
        j["createdAt"] = Json(d.createdAt);
        return j;
    }
}
