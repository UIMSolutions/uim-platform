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

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto j = req.json;
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
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Provider created");

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

            auto providers = usecase.list(tenantId);

            auto jarr = providers.map!(p => toJson(p)).array.toJson;{

            auto resp = Json.emptyObject
                .set("count", providers.length)
                .set("resources", jarr)
                .set("message", "Provider list retrieved successfully");
                
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            import std.algorithm : endsWith;
            auto path = req.requestURI.to!string;
            if (path.endsWith("/activate") || path.endsWith("/deactivate") || path.endsWith("/sync")) return;

            auto tenantId = precheck.tenantId;
            auto id = extractIdFromPath(path);
            auto p = usecase.getById(tenantId, id);
            if (p.isNull) {
                writeError(res, 404, "Provider not found");
                return;
            }
            res.writeJsonBody(toJson(p), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            auto id = precheck.id;
            auto j = req.json;
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
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Provider updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 9]; // remove "/activate"
            auto id = extractIdFromPath(stripped);
            auto tenantId = precheck.tenantId;

            auto result = usecase.activate(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Provider activated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 11]; // remove "/deactivate"
            auto id = extractIdFromPath(stripped);
            auto tenantId = precheck.tenantId;

            auto result = usecase.deactivate(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Provider deactivated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleSync(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 5]; // remove "/sync"
            auto id = extractIdFromPath(stripped);
            auto tenantId = precheck.tenantId;

            auto result = usecase.sync(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Provider sync initiated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            auto tenantId = precheck.tenantId;
            auto id = precheck.id;
            auto result = usecase.deleteTaskProvider(tenantId, TaskProviderId(id));
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Provider deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json providerToJson(TaskProvider p) {
        return Json.emptyObject
        .set("id", p.id)
        .set("tenantId", p.tenantId)
        .set("name", p.name)
        .set("description", p.description)
        .set("providerType", p.providerType.to!string)
        .set("status", p.status.to!string)
        .set("authType", p.authType.to!string)
        .set("endpointUrl", p.endpointUrl)
        .set("authEndpointUrl", p.authEndpointUrl)
        .set("clientId", p.clientId)
        .set("lastSyncAt", p.lastSyncAt)
        .set("lastSyncError", p.lastSyncError)
        .set("taskCount", p.taskCount)
        .set("createdBy", p.createdBy)
        .set("createdAt", p.createdAt);
    }
}
