/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task_provider;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskProviderController : PlatformController {
    private ManageTaskProvidersUseCase uc;

    this(ManageTaskProvidersUseCase uc) {
        this.uc = uc;
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

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateTaskProviderRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.providerType = j.getString("providerType");
            r.authType = j.getString("authType");
            r.endpointUrl = j.getString("endpointUrl");
            r.authEndpointUrl = j.getString("authEndpointUrl");
            r.clientId = j.getString("clientId");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Provider created");
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
            auto providers = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (p; providers) {
                jarr ~= providerToJson(p);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) providers.length);
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
            if (path.endsWith("/activate") || path.endsWith("/deactivate") || path.endsWith("/sync")) return;

            TenantId tenantId = req.getTenantId;
            auto id = extractIdFromPath(path);
            auto p = uc.get_(tenantId, id);
            if (p.id.isEmpty) {
                writeError(res, 404, "Provider not found");
                return;
            }
            res.writeJsonBody(providerToJson(p), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateTaskProviderRequest r;
            r.tenantId = req.getTenantId;
            r.id = id;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.endpointUrl = j.getString("endpointUrl");
            r.authEndpointUrl = j.getString("authEndpointUrl");
            r.clientId = j.getString("clientId");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Provider updated");
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
                resp["message"] = Json("Provider activated");
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
                resp["message"] = Json("Provider deactivated");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleSync(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 5]; // remove "/sync"
            auto id = extractIdFromPath(stripped);
            TenantId tenantId = req.getTenantId;

            auto result = uc.sync(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Provider sync initiated");
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
            TenantId tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Provider deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json providerToJson(TaskProvider p) {
        import std.conv : to;
        auto j = Json.emptyObject;
        j["id"] = Json(p.id);
        j["tenantId"] = Json(p.tenantId);
        j["name"] = Json(p.name);
        j["description"] = Json(p.description);
        j["providerType"] = Json(p.providerType.to!string);
        j["status"] = Json(p.status.to!string);
        j["authType"] = Json(p.authType.to!string);
        j["endpointUrl"] = Json(p.endpointUrl);
        j["authEndpointUrl"] = Json(p.authEndpointUrl);
        j["clientId"] = Json(p.clientId);
        j["lastSyncAt"] = Json(p.lastSyncAt);
        j["lastSyncError"] = Json(p.lastSyncError);
        j["taskCount"] = Json(p.taskCount);
        j["createdBy"] = Json(p.createdBy);
        j["createdAt"] = Json(p.createdAt);
        return j;
    }
}
