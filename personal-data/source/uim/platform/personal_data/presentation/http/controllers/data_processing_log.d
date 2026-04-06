/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.data_processing_log;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class DataProcessingLogController : SAPController {
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
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = jsonStr(j, "id");
            r.dataSubjectId = jsonStr(j, "dataSubjectId");
            r.requestId = jsonStr(j, "requestId");
            r.applicationId = jsonStr(j, "applicationId");
            r.entryType = jsonStr(j, "entryType");
            r.severity = jsonStr(j, "severity");
            r.action = jsonStr(j, "action");
            r.details = jsonStr(j, "details");
            r.ipAddress = jsonStr(j, "ipAddress");
            r.createdBy = jsonStr(j, "createdBy");

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
            auto tenantId = req.headers.get("X-Tenant-Id", "");
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
            foreach (ref l; logs) {
                jarr ~= logToJson(l);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) logs.length);
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
            if (l.id.length == 0) {
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

    private Json logToJson(ref DataProcessingLog l) {
        auto j = Json.emptyObject;
        j["id"] = Json(l.id);
        j["dataSubjectId"] = Json(l.dataSubjectId);
        j["requestId"] = Json(l.requestId);
        j["applicationId"] = Json(l.applicationId);
        j["entryType"] = Json(l.entryType.to!string);
        j["severity"] = Json(l.severity.to!string);
        j["action"] = Json(l.action);
        j["details"] = Json(l.details);
        j["ipAddress"] = Json(l.ipAddress);
        j["createdBy"] = Json(l.createdBy);
        j["createdAt"] = Json(l.createdAt);
        return j;
    }
}
