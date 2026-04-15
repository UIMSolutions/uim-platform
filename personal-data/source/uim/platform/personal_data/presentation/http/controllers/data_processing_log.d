/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.data_processing_log;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class DataProcessingLogController : PlatformController {
    private ManageDataProcessingLogsUseCase uc;

    this(ManageDataProcessingLogsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/personal-data/logs", &handleList);
        router.get("/api/v1/personal-data/logs/*", &handleGet);
        router.post("/api/v1/personal-data/logs", &handleCreate);
        router.delete_("/api/v1/personal-data/logs/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateDataProcessingLogRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.dataSubjectId = j.getString("dataSubjectId");
            r.requestId = j.getString("requestId");
            r.applicationId = j.getString("applicationId");
            r.entryType = j.getString("entryType");
            r.severity = j.getString("severity");
            r.action = j.getString("action");
            r.details = j.getString("details");
            r.ipAddress = j.getString("ipAddress");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Processing log entry created");
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
            auto params = req.queryParams();
            auto dataSubjectId = params.get("dataSubjectId", "");
            auto requestId = params.get("requestId", "");

            DataProcessingLog[] logs;
            if (dataSubjectId.length > 0) {
                logs = uc.listByDataSubject(dataSubjectId);
            } else if (requestId.length > 0) {
                logs = uc.listByRequest(requestId);
            } else {
                logs = uc.list(tenantId);
            }

            auto jarr = Json.emptyArray;
            foreach (l; logs) {
                jarr ~= logToJson(l);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(logs.length);
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
            auto l = uc.get_(id);
            if (l.id.isEmpty) {
                writeError(res, 404, "Processing log entry not found");
                return;
            }
            res.writeJsonBody(logToJson(l), 200);
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
                resp["message"] = Json("Processing log entry deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json logToJson(DataProcessingLog l) {
        return Json.emptyObject
        .set("id", l.id)
        .set("dataSubjectId", l.dataSubjectId)
        .set("requestId", l.requestId)
        .set("applicationId", l.applicationId)
        .set("entryType", l.entryType.to!string)
        .set("severity", l.severity.to!string)
        .set("action", l.action)
        .set("details", l.details)
        .set("ipAddress", l.ipAddress)
        .set("createdBy", l.createdBy)
        .set("createdAt", l.createdAt);
    }
}
