/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.data_processing_log;

import uim.platform.personal_data;

// mixin(ShowModule!());

@safe:

class DataProcessingLogController : ManageHttpController {
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

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateDataProcessingLogRequest r;
        r.tenantId = tenantId;
        r.id = precheck.id;
        r.dataSubjectId = data.getString("dataSubjectId");
        r.requestId = data.getString("requestId");
        r.applicationId = data.getString("applicationId");
        r.entryType = data.getString("entryType");
        r.severity = data.getString("severity");
        r.action = data.getString("action");
        r.details = data.getString("details");
        r.ipAddress = data.getString("ipAddress");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createProcessingLog(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("id", result.id);
        return successResponse("Data processing log entry created successfully", "Created", 201, resp);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto params = req.queryParams();
        auto dataSubjectId = params.get("dataSubjectId", "");
        auto requestId = params.get("requestId", "");

        DataProcessingLog[] logs;
        if (!dataSubjectId.isEmpty) {
            logs = usecase.listProcessingLogs(tenantId, dataSubjectId);
        } else if (!requestId.isEmpty) {
            logs = usecase.listProcessingLogs(tenantId, requestId);
        } else {
            logs = usecase.listProcessingLogs(tenantId);
        }

        auto jarr = logs.map!(l => logToJson(l)).array.toJson;

        auto resp = Json.emptyObject
            .set("count", logs.length)
            .set("resources", jarr)
            .set("message", "Data Processing log list retrieved successfully");

        return successResponse("Data Processing log list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataProcessingLogId(precheck.id);
        auto l = usecase.getProcessingLog(tenantId, id);
        if (l.isNull)
            return errorResponse("Processing log entry not found", 404);

        return successResponse("Data Processing log entry retrieved successfully", "Retrieved", 200, l
                .toJson);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataProcessingLogId(precheck.id);

        auto result = usecase.deleteProcessingLog(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Processing log entry deleted");

        return successResponse("Data Processing log entry deleted successfully", "Deleted", 200, resp);

    }

}
