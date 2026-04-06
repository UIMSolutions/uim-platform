/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.data_context;

// import uim.platform.situation_automation.application.usecases.manage.data_contexts;
// import uim.platform.situation_automation.application.dto;
// import uim.platform.situation_automation.presentation.http.json_utils;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

class DataContextController : SAPController {
    private ManageDataContextsUseCase uc;

    this(ManageDataContextsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/situation-automation/data-contexts", &handleList);
        router.get("/api/v1/situation-automation/data-contexts/*", &handleGet);
        router.post("/api/v1/situation-automation/data-contexts", &handleCreate);
        router.delete_("/api/v1/situation-automation/data-contexts/*", &handleDelete);
        router.post("/api/v1/situation-automation/data-contexts/delete-personal-data", &handleDeletePersonalData);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateDataContextRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.instanceId = jsonStr(j, "instanceId");
            r.id = jsonStr(j, "id");
            r.entityId = jsonStr(j, "entityId");
            r.entityTypeId = jsonStr(j, "entityTypeId");
            r.data = jsonKeyValuePairs(j, "data");
            r.sourceSystem = jsonStr(j, "sourceSystem");
            r.containsPersonalData = jsonBool(j, "containsPersonalData");
            r.expiresAt = jsonLong(j, "expiresAt");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Data context created");
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
            auto contexts = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref d; contexts) {
                auto dj = Json.emptyObject;
                dj["id"] = Json(d.id);
                dj["instanceId"] = Json(d.instanceId);
                dj["entityId"] = Json(d.entityId);
                dj["entityTypeId"] = Json(d.entityTypeId);
                dj["sourceSystem"] = Json(d.sourceSystem);
                dj["containsPersonalData"] = Json(d.containsPersonalData);
                dj["capturedAt"] = Json(d.capturedAt);
                dj["expiresAt"] = Json(d.expiresAt);
                jarr ~= dj;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) contexts.length);
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
                writeError(res, 404, "Data context not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(d.id);
            resp["instanceId"] = Json(d.instanceId);
            resp["entityId"] = Json(d.entityId);
            resp["entityTypeId"] = Json(d.entityTypeId);
            resp["sourceSystem"] = Json(d.sourceSystem);
            resp["containsPersonalData"] = Json(d.containsPersonalData);
            resp["capturedAt"] = Json(d.capturedAt);
            resp["expiresAt"] = Json(d.expiresAt);
            res.writeJsonBody(resp, 200);
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
                resp["message"] = Json("Data context deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDeletePersonalData(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto result = uc.removePersonalData(tenantId);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["message"] = Json("Personal data contexts deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
