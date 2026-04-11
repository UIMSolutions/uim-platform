/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.visibility;

import uim.platform.process_automation.application.usecases.manage.visibilities;
import uim.platform.process_automation.application.dto;
import uim.platform.process_automation.presentation.http.json_utils;

import uim.platform.process_automation;

class VisibilityController : PlatformController {
    private ManageVisibilitiesUseCase uc;

    this(ManageVisibilitiesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/process-automation/visibility", &handleList);
        router.get("/api/v1/process-automation/visibility/*", &handleGet);
        router.post("/api/v1/process-automation/visibility", &handleCreate);
        router.put("/api/v1/process-automation/visibility/*", &handleUpdate);
        router.delete_("/api/v1/process-automation/visibility/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateVisibilityRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.dashboardType = j.getString("dashboardType");
            r.processIds = jsonStrArray(j, "processIds");
            r.refreshIntervalSeconds = j.getString("refreshIntervalSeconds");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Visibility dashboard created");
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
            auto dashboards = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (v; dashboards) {
                auto vj = Json.emptyObject;
                vj["id"] = Json(v.id);
                vj["name"] = Json(v.name);
                vj["description"] = Json(v.description);
                vj["status"] = Json(v.status.to!string);
                vj["dashboardType"] = Json(v.dashboardType.to!string);
                vj["createdAt"] = Json(v.createdAt);
                vj["modifiedAt"] = Json(v.modifiedAt);
                jarr ~= vj;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(dashboards.length);
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
            auto v = uc.get_(id);
            if (v.id.isEmpty) {
                writeError(res, 404, "Visibility dashboard not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(v.id);
            resp["name"] = Json(v.name);
            resp["description"] = Json(v.description);
            resp["status"] = Json(v.status.to!string);
            resp["dashboardType"] = Json(v.dashboardType.to!string);
            resp["processIds"] = stringsToJsonArray(v.processIds);
            resp["refreshIntervalSeconds"] = Json(v.refreshIntervalSeconds);
            resp["createdBy"] = Json(v.createdBy);
            resp["modifiedBy"] = Json(v.modifiedBy);
            resp["createdAt"] = Json(v.createdAt);
            resp["modifiedAt"] = Json(v.modifiedAt);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateVisibilityRequest r;
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.refreshIntervalSeconds = j.getString("refreshIntervalSeconds");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Visibility dashboard updated");
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
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Visibility dashboard deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
