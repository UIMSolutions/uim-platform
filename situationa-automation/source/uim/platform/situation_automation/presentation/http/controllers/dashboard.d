/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.dashboard;

// import uim.platform.situation_automation.application.usecases.manage.dashboards;
// import uim.platform.situation_automation.application.dto;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

class DashboardController : SAPController {
    private ManageDashboardsUseCase uc;

    this(ManageDashboardsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/situation-automation/dashboards", &handleList);
        router.get("/api/v1/situation-automation/dashboards/*", &handleGet);
        router.post("/api/v1/situation-automation/dashboards", &handleCreate);
        router.put("/api/v1/situation-automation/dashboards/*", &handleUpdate);
        router.delete_("/api/v1/situation-automation/dashboards/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateDashboardRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = jsonStr(j, "id");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.type = jsonStr(j, "type");
            r.refreshIntervalSeconds = jsonInt(j, "refreshIntervalSeconds");
            r.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Dashboard created");
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
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto dashboards = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref d; dashboards) {
                auto dj = Json.emptyObject;
                dj["id"] = Json(d.id);
                dj["name"] = Json(d.name);
                dj["description"] = Json(d.description);
                dj["type"] = Json(d.type.to!string);
                dj["refreshIntervalSeconds"] = Json(cast(long) d.refreshIntervalSeconds);
                dj["createdAt"] = Json(d.createdAt);
                jarr ~= dj;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) dashboards.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto d = uc.get_(id);
            if (d.id.length == 0) {
                writeError(res, 404, "Dashboard not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(d.id);
            resp["name"] = Json(d.name);
            resp["description"] = Json(d.description);
            resp["type"] = Json(d.type.to!string);
            resp["refreshIntervalSeconds"] = Json(cast(long) d.refreshIntervalSeconds);
            resp["createdBy"] = Json(d.createdBy);
            resp["modifiedBy"] = Json(d.modifiedBy);
            resp["createdAt"] = Json(d.createdAt);
            resp["modifiedAt"] = Json(d.modifiedAt);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateDashboardRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.refreshIntervalSeconds = jsonInt(j, "refreshIntervalSeconds");
            r.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Dashboard updated");
                res.writeJsonBody(resp, 200);
            } else {
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
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Dashboard deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
