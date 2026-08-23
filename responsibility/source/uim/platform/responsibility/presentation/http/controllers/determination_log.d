/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.presentation.http.controllers.determination_log;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class DeterminationLogController : ManageHttpController {
    private ManageDeterminationLogsUseCase _uc;

    this(ManageDeterminationLogsUseCase uc) {
        _uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/responsibility/determination-logs", &handleList);
        router.get("/api/v1/responsibility/determination-logs/*", &handleGet);
        router.delete_("/api/v1/responsibility/determination-logs/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = _uc.listLogs(tenantId).map!(e => e.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", items.length)
            .set("status", "success").set("statusCode", 200)
            .set("resources", items);

        return successResponse("Determination logs listed successfully", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
        auto id = DeterminationLogId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid log id", 400);

        auto e = _uc.getLog(tenantId, id);
        if (e.isNull)
            return errorResponse("Log not found", 404);

        auto responseData = Json.emptyObject
            .set("status", "success").set("statusCode", 200)
            .set("resource", e.toJson());
        return successResponse("Determination log retrieved successfully", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto result = super.deleteHandler(req);
        if (result.hasError)
            return errorResponse(result.error, result.statusCode);

        auto tenantId = TenantId(result.getString("tenantId"));
        auto id = DeterminationLogId(result.id);
        if (id.isNull)
            return errorResponse("Invalid log id", 400);

        auto deleteResult = _uc.deleteLog(tenantId, id);
        if (!deleteResult.success)
            return errorResponse(deleteResult.error, deleteResult.statusCode);

        auto responseData = Json.emptyObject
            .set("id", deleteResult.id)
            .set("status", "success")
            .set("statusCode", 200);
        return successResponse("Determination log deleted successfully", 200, responseData);
    }

}
