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
    private ManageDataProcessingLogsUseCase usecase;

    this(ManageDataProcessingLogsUseCase usecase) {
        this.usecase = usecase;
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
            r.tenantId = tenantId;
            r.id = j.getString("id");
            r.dataSubjectId = j.getString("dataSubjectId");
            r.requestId = j.getString("requestId");
            r.applicationId = j.getString("applicationId");
            r.entryType = j.getString("entryType");
            r.severity = j.getString("severity");
            r.action = j.getString("action");
            r.details = j.getString("details");
            r.ipAddress = j.getString("ipAddress");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Processing log entry created");

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
            auto tenantId = req.getTenantId;
            auto params = req.queryParams();
            auto dataSubjectId = params.get("dataSubjectId", "");
            auto requestId = params.get("requestId", "");

            DataProcessingLog[] logs;
            if (!dataSubjectId.isEmpty) {
                logs = usecase.listDataProcessingLogs(tenantId, dataSubjectId);
            } else if (!requestId.isEmpty) {
                logs = usecase.listDataProcessingLogs(tenantId, requestId);
            } else {
                logs = usecase.listDataProcessingLogs(tenantId);
            }

            auto jarr = logs.map!(l => logToJson(l)).array;

            auto resp = Json.emptyObject
              .set("count", logs.length)
              .set("resources", jarr)
              .set("message", "Processing log list retrieved successfully") ;

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = DataProcessingLogId(extractIdFromPath(req.requestURI.to!string));
            auto l = usecase.getDataProcessingLog(tenantId, id);
            if (l.isNull) {
                writeError(res, 404, "Processing log entry not found");
                return;
            }
            res.writeJsonBody(toJson(l), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = DataProcessingLogId(extractIdFromPath(req.requestURI.to!string));

            auto result = usecase.deleteDataProcessingLog(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Processing log entry deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

}
