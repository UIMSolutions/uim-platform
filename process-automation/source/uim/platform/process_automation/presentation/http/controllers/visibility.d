/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.visibility;
// import uim.platform.process_automation.application.visibilitiess.manage.visibilities;
// import uim.platform.process_automation.application.dto;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:

class VisibilityController : ManageController {
    private ManageVisibilitiesUseCase visibilityUsecase;

    this(ManageVisibilitiesUseCase visibilityUsecase) {
        this.visibilityUsecase = visibilityUsecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/process-automation/visibility", &handleList);
        router.get("/api/v1/process-automation/visibility/*", &handleGet);
        router.post("/api/v1/process-automation/visibility", &handleCreate);
        router.put("/api/v1/process-automation/visibility/*", &handleUpdate);
        router.delete_("/api/v1/process-automation/visibility/*", &handleDelete);
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto j = req.json;
            CreateVisibilityRequest r;
            r.tenantId = tenantId;
            r.visibilityId = VisibilityId(j.getString("id"));
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.dashboardType = j.getString("dashboardType");
            r.processIds = getStrings(j, "processIds");
            r.refreshIntervalSeconds = j.getString("refreshIntervalSeconds");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = visibilityUsecase.createVisibility(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Visibility dashboard created");

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

            auto items = visibilityUsecase.listVisibilities(tenantId);
            auto jarr = Json.emptyArray;
            foreach (v; items) {
                jarr ~= Json.emptyObject
                    .set("id", v.id)
                    .set("name", v.name)
                    .set("description", v.description)
                    .set("status", v.status.to!string)
                    .set("dashboardType", v.dashboardType.to!string)
                    .set("createdAt", v.createdAt)
                    .set("updatedAt", v.updatedAt);
            }

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {

            auto tenantId = req.getTenantId;
            auto id = VisibilityId(extractIdFromPath(req.requestURI.to!string));
            auto v = visibilityUsecase.getVisibility(tenantId, id);
            if (v.isNull) {
                writeError(res, 404, "Visibility dashboard not found");
                return;
            }

            auto resp = Json.emptyObject
                .set("id", v.id)
                .set("name", v.name)
                .set("description", v.description)
                .set("status", v.status.to!string)
                .set("dashboardType", v.dashboardType.to!string)
                .set("processIds", v.processIds.map!(pid => Json(pid.value)).array.toJson)
                .set("refreshIntervalSeconds", Json(v.refreshIntervalSeconds))
                .set("createdBy", Json(v.createdBy.value))
                .set("updatedBy", Json(v.updatedBy.value))
                .set("createdAt", Json(v.createdAt))
                .set("updatedAt", Json(v.updatedAt));

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto j = req.json;
            UpdateVisibilityRequest r;
            r.tenantId = tenantId;
            r.visibilityId = VisibilityId(extractIdFromPath(req.requestURI.to!string));
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.refreshIntervalSeconds = j.getString("refreshIntervalSeconds");
            r.updatedBy = UserId(j.getString("updatedBy"));

            auto result = visibilityUsecase.updateVisibility(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Visibility dashboard updated");

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

            auto id = VisibilityId(extractIdFromPath(req.requestURI.to!string));
            auto result = visibilityUsecase.deleteVisibility(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Visibility dashboard deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
