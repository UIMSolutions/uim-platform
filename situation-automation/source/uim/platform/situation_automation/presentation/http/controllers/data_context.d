/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.data_context;
// import uim.platform.situation_automation.application.usecases.manage.data_contexts;
// import uim.platform.situation_automation.application.dto;

import uim.platform.situation_automation;

// mixin(ShowModule!());

@safe:

class DataContextController : ManageHttpController {
    private ManageDataContextsUseCase usecase;

    this(ManageDataContextsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/situation-automation/data-contexts", &handleList);
        router.get("/api/v1/situation-automation/data-contexts/*", &handleGet);
        router.post("/api/v1/situation-automation/data-contexts", &handleCreate);
        router.delete_("/api/v1/situation-automation/data-contexts/*", &handleDelete);
        router.post("/api/v1/situation-automation/data-contexts/delete-personal-data", &handleDeletePersonalData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateDataContextRequest r;
        r.tenantId = tenantId;
        r.situationInstanceId = SituationInstanceId(data.getString("instanceId"));
        r.dataContextId = DataContextId(precheck.id);
        r.entityId = data.getString("entityId");
        r.entityTypeId = EntityTypeId(data.getString("entityTypeId"));
        r.data = jsonKeyValuePairs(j, "data");
        r.sourceSystem = data.getString("sourceSystem");
        r.containsPersonalData = data.getBoolean("containsPersonalData");
        r.expiresAt = data.getLong("expiresAt");

        auto result = usecase.createDataContext(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Data context created successfully", "Created", 201, resp);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto contexts = usecase.listDataContexts(tenantId);

        auto jarr = Json.emptyArray;
        foreach (d; contexts) {
            jarr ~= Json.emptyObject
                .set("id", d.id)
                .set("instanceId", d.instanceId)
                .set("entityId", d.entityId)
                .set("entityTypeId", d.entityTypeId)
                .set("sourceSystem", d.sourceSystem)
                .set("containsPersonalData", d.containsPersonalData)
                .set("capturedAt", d.capturedAt)
                .set("expiresAt", d.expiresAt);
        }

        auto resp = Json.emptyObject
            .set("count", Json(contexts.length))
            .set("resources", jarr);

        return successResponse("Data contexts retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataContextId(precheck.id);
        auto d = usecase.getDataContext(tenantId, id);
        if (d.isNull) {
            writeError(res, 404, "Data context not found");
            return;
        }

        auto resp = Json.emptyObject
            .set("id", d.id.value)
            .set("instanceId", d.instanceId.value)
            .set("entityId", d.entityId)
            .set("entityTypeId", d.entityTypeId.value)
            .set("sourceSystem", d.sourceSystem)
            .set("containsPersonalData", d.containsPersonalData)
            .set("capturedAt", d.capturedAt)
            .set("expiresAt", d.expiresAt);

        return successResponse("Data context retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = DataContextId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid data context ID", 400);

        auto result = usecase.deleteDataContext(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Data context deleted successfully", "Deleted", 200, resp);

    }

    protected Json deletePersonalDataHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto result = usecase.deletePersonalData(tenantId);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("message", "Personal data contexts deleted");
        return successResponse("Personal data contexts deleted successfully", "Deleted", 200, resp);
    }

    mixin(HandleTemplate!("handleDeletePersonalData", "deletePersonalDataHandler"));

}
