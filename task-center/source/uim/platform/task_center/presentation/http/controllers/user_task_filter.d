/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.user_task_filter;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class UserTaskFilterController : ManageController {
    private ManageUserTaskFiltersUseCase usecase;

    this(ManageUserTaskFiltersUseCase usecase) {
        this.usecase = usecase;
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

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            CreateUserTaskFilterRequest r;
            r.tenantId = tenantId;
            r.id = j.getString("id");
            r.userId = j.getString("userId");
            r.name = j.getString("name");
            r.description = j.getString("description");

            auto result = usecase.create(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Filter created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto params = req.queryParams();
            auto userId = params.get("userId", "");

            UserTaskFilter[] filters = !userId.isEmpty
                ? usecase.listUserTaskFilters(tenantId, userId) : [];

            auto jarr = filters.map!(f => toJson(f)).array.toJson;

            auto resp = Json.emptyObject
                .set("count", filters.length)
                .set("resources", jarr)
                .set("message", "Filter list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            import std.algorithm : endsWith;

            auto path = req.requestURI.to!string;
            if (path.endsWith("/default"))
                return;

            auto tenantId = req.getTenantId;
            auto id = UserTaskFilterId(precheck.id);
            auto f = usecase.getUserTaskFilter(tenantId, id);
            if (f.isNull) {
                writeError(res, 404, "Filter not found");
                return;
            }
            res.writeJsonBody(toJson(f), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto id = UserTaskFilterId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;
            UpdateUserTaskFilterRequest r;
            r.tenantId = tenantId;
            r.userTaskFilterId = id;
            r.name = j.getString("name");
            r.description = j.getString("description");

            auto result = usecase.update(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Filter updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleSetDefault(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 8]; // remove "/default"
            auto id = UserTaskFilterId(extractIdFromPath(stripped));
            auto tenantId = req.getTenantId;

            auto result = usecase.setDefaultUserTaskFilter(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Filter set as default");

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
            auto tenantId = req.getTenantId;
            auto id = UserTaskFilterId(extractIdFromPath(req.requestURI.to!string));
            auto result = usecase.deleteUserTaskFilter(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Filter deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

}
