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
        auto pre = super.listHandler(req);
        if (!pre.success)
            return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto items = _uc.listLogs(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("status", "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);
            
        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto id = DeterminationLogId(precheck.id);
        auto e = _uc.getLog(tenantId, id);
        if (e.isNull)
            return errorResponse("Log not found", 404);

        return e.toJson().set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto result = super.deleteHandler(req);
        if (!result.success)
            return Json.emptyObject.set("error", result.error);
        auto tenantId = TenantId(result.gString("tenantId"));
        auto id = DeterminationLogId(result.id);
        auto deleteResult = _uc.deleteLog(tenantId, id);
        if (!deleteResult.success)
            return Json.emptyObject.set("error", deleteResult.message).set("statusCode", 404);
        return Json.emptyObject.set("id", deleteResult.id).set("status", "success").set("statusCode", 200);
    }
}
