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

class DashboardController : PlatformController {
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
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.type = j.getString("type");
            r.refreshIntervalSeconds = j.getInteger("refreshIntervalSeconds");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Dashboard created");

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
            auto dashboards = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (d; dashboards) {
                jarr ~= Json.emptyObject
                .set("id", d.id)
                .set("name", d.name)
                .set("description", d.description)
                .set("type", d.type.to!string)
                .set("refreshIntervalSeconds", d.refreshIntervalSeconds)
                .set("createdAt", d.createdAt);
            }

            auto resp = Json.emptyObject
                .set("count", Json(dashboards.length))
                .set("resources", jarr)
                .set("message", "Dashboards retrieved");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto d = uc.getById(id);
            if (d.id.isEmpty) {
                writeError(res, 404, "Dashboard not found");
                return;
            }

            auto resp = Json.emptyObject
                .set("id", d.id)
                .set("name", d.name)
                .set("description", d.description)
                .set("type", d.type.to!string)
                .set("refreshIntervalSeconds", d.refreshIntervalSeconds)
                .set("createdBy", d.createdBy)
                .set("modifiedBy", d.modifiedBy)
                .set("createdAt", d.createdAt)
                .set("updatedAt", d.updatedAt);

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
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.refreshIntervalSeconds = j.getInteger("refreshIntervalSeconds");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Dashboard updated");

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
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Dashboard deleted");
                    
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
