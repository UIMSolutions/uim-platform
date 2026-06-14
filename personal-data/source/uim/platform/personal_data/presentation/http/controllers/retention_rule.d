/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.retention_rule;

import uim.platform.personal_data;

// mixin(ShowModule!());

@safe:

class RetentionRuleController : ManageHttpController {
    private ManageRetentionRulesUseCase usecase;

    this(ManageRetentionRulesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/personal-data/retention-rules", &handleList);
        router.get("/api/v1/personal-data/retention-rules/*", &handleGet);
        router.post("/api/v1/personal-data/retention-rules", &handleCreate);
        router.put("/api/v1/personal-data/retention-rules/*", &handleUpdate);
        router.delete_("/api/v1/personal-data/retention-rules/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateRetentionRuleRequest r;
        r.tenantId = tenantId;
        r.id = precheck.id;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.retentionPeriod = data.getString("retentionPeriod");
        r.periodUnit = data.getString("periodUnit");
        r.autoDelete = data.getBoolean("autoDelete");
        r.notifyBeforeExpiry = data.getBoolean("notifyBeforeExpiry");
        r.notifyDaysBefore = data.getString("notifyDaysBefore");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.create(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Retention rule created");

        return successResponse("Retention rule created successfully", 201, resp);
}

override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;

    auto rules = usecase.list(tenantId);

    auto jarr = rules.map!(r => toJson(r)).array.toJson;

    auto resp = Json.emptyObject
        .set("count", rules.length)
        .set("resources", jarr)
        .set("message", "Retention rule list retrieved successfully");

    return successResponse("Retention rule list retrieved successfully", 200, resp);
}

override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;

    auto id = precheck.id;
    auto r = usecase.getById(tenantId, id);
    if (r.isNull) {
        writeError(res, 404, "Retention rule not found");
        return;
    }
    res.writeJsonBody(toJson(r), 200);
}
 catch (Exception e) {
    writeError(res, 500, "Internal server error");
}
}

override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    UpdateRetentionRuleRequest r;
    r.tenantId = tenantId;
    r.id = precheck.id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.retentionPeriod = data.getString("retentionPeriod");
    r.periodUnit = data.getString("periodUnit");
    r.autoDelete = data.getBoolean("autoDelete");
    r.notifyBeforeExpiry = data.getBoolean("notifyBeforeExpiry");
    r.notifyDaysBefore = data.getString("notifyDaysBefore");
    r.updatedBy = UserId(data.getString("updatedBy"));

    auto result = usecase.update(r);
    if (result.hasError)
        return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
        .set("id", result.id)
        .set("message", "Retention rule updated");

    return successResponse("Retention rule updated successfully", 200, resp);
}

override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;

    auto result = usecase.deleteRetentionRule(id);
    if (result.hasError)
        return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
        .set("id", result.id);

    return successResponse("Retention rule deleted successfully", 200, resp);
}
}
