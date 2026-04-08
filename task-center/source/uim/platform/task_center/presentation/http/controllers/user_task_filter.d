/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.user_task_filter;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class UserTaskFilterController : SAPController {
    private ManageUserTaskFiltersUseCase uc;

    this(ManageUserTaskFiltersUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/task-center/filters", &handleList);
        router.get("/api/v1/task-center/filters/*", &handleGet);
        router.post("/api/v1/task-center/filters", &handleCreate);
        router.put("/api/v1/task-center/filters/*", &handleUpdate);
        router.post("/api/v1/task-center/filters/*/default", &handleSetDefault);
        router.delete_("/api/v1/task-center/filters/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateUserTaskFilterRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.userId = j.getString("userId");
            r.name = j.getString("name");
            r.description = j.getString("description");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Filter created");
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
            auto tenantId = req.getTenantId;
            auto params = req.queryParams();
            auto userId = params.get("userId", "");

            UserTaskFilter[] filters;
            if (userId.length > 0) {
                filters = uc.listByUser(tenantId, userId);
            } ) {
                filters = [];
            }

            auto jarr = Json.emptyArray;
            foreach (ref f; filters) {
                jarr ~= filterToJson(f);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) filters.length);
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
            if (path.endsWith("/default")) return;

            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(path);
            auto f = uc.get_(tenantId, id);
            if (f.id.length == 0) {
                writeError(res, 404, "Filter not found");
                return;
            }
            res.writeJsonBody(filterToJson(f), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateUserTaskFilterRequest r;
            r.tenantId = req.getTenantId;
            r.id = id;
            r.name = j.getString("name");
            r.description = j.getString("description");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Filter updated");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleSetDefault(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 8]; // remove "/default"
            auto id = extractIdFromPath(stripped);
            auto tenantId = req.getTenantId;

            auto result = uc.setDefault(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Filter set as default");
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
            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Filter deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json filterToJson(ref UserTaskFilter f) {
        auto j = Json.emptyObject;
        j["id"] = Json(f.id);
        j["tenantId"] = Json(f.tenantId);
        j["userId"] = Json(f.userId);
        j["name"] = Json(f.name);
        j["description"] = Json(f.description);
        j["isDefault"] = Json(f.isDefault);
        j["createdAt"] = Json(f.createdAt);
        j["modifiedAt"] = Json(f.modifiedAt);
        return j;
    }
}
