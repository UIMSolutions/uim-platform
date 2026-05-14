/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task_definition;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskDefinitionController : PlatformController {
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

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            CreateTaskDefinitionRequest r;
            r.tenantId = tenantId;
            r.id = j.getString("id");
            r.providerId = j.getString("providerId");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.category = j.getString("category");
            r.taskSchema = j.getString("taskSchema");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createTaskDefinition(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task definition created");
                    
                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto params = req.queryParams();
            auto providerId = params.get("providerId", "");

            TaskDefinition[] defs = !providerId.isEmpty 
                ? usecase.listTaskDefinitions(tenantId, providerId) : usecase.listTaskDefinitions(tenantId);

            auto jarr = defs.map!(d => toJson(d)).array.toJson;

            auto resp = Json.emptyObject
                .set("count", defs.length)
                .set("resources", jarr)
                .set("message", "Task definition list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.algorithm : endsWith;
            auto path = req.requestURI.to!string;
            if (path.endsWith("/activate") || path.endsWith("/deactivate")) return;

            auto tenantId = req.getTenantId;
            auto id = TaskDefinitionId(extractIdFromPath(path));
            auto d = usecase.getTaskDefinition(tenantId, id);
            if (d.isNull) {
                writeError(res, 404, "Task definition not found");
                return;
            }
            res.writeJsonBody(toJson(d), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TaskDefinitionId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;
            UpdateTaskDefinitionRequest r;
            r.tenantId = tenantId;
            r.id = id;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.category = j.getString("category");
            r.taskSchema = j.getString("taskSchema");
            r.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateTaskDefinition(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task definition updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 9]; // remove "/activate"
            auto id = TaskDefinitionId(extractIdFromPath(stripped));

            auto result = usecase.activateTaskDefinition(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task definition activated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 11]; // remove "/deactivate"
            auto id = TaskDefinitionId(extractIdFromPath(stripped));

            auto result = usecase.deactivateTaskDefinition(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task definition deactivated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto tenantId = req.getTenantId;
            auto result = usecase.deleteTaskDefinition(tenantId, TaskDefinitionId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task definition deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json defToJson(TaskDefinition d) {
        return Json.emptyObject
        .set("id", d.id)
        .set("tenantId", d.tenantId)
        .set("providerId", d.providerId)
        .set("name", d.name)
        .set("description", d.description)
        .set("category", d.category.to!string)
        .set("taskSchema", d.taskSchema)
        .set("isActive", d.isActive)
        .set("requiresClaim", d.requiresClaim)
        .set("createdBy", d.createdBy)
        .set("createdAt", d.createdAt);
    }
}
