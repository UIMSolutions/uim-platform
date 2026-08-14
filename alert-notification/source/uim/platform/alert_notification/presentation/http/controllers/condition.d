/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.presentation.http.controllers.condition;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

class ConditionController : ManageHttpController {
    private ManageConditionsUseCase usecase;

    this(ManageConditionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/alert-notification/conditions", &handleCreate);
        router.get("/api/v1/alert-notification/conditions", &handleList);
        router.get("/api/v1/alert-notification/conditions/*", &handleGet);
        router.put("/api/v1/alert-notification/conditions/*", &handleUpdate);
        router.delete_("/api/v1/alert-notification/conditions/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        auto dto = CreateConditionRequest();
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.propertyKey = data.getString("propertyKey");
        dto.predicate = data.getString("predicate");
        dto.propertyValue = data.getString("propertyValue");
        dto.mandatory = data.getBool("mandatory", false);
        auto result = usecase.createCondition(tenantId, dto);
        if (result.hasError())
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Condition created successfully", "Created", 201, responseData);
    }

    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = TenantId(req.headers.get("X-Tenant-Id", "default"));
        auto result = usecase.listConditions(tenantId);
        res.writeJsonBody(result.data, cast(int)HTTPStatus.ok);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = req.requestPath.to!string.split("/")[$ - 1];
        auto result = usecase.getCondition(tenantId, id);
        if (!result.success) {
            writeError(res, cast(int)HTTPStatus.notFound, result.message);
            return;
        }
        res.writeJsonBody(result.data, cast(int)HTTPStatus.ok);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = req.requestPath.to!string.split("/")[$ - 1];
        auto data = precheck.data;
        UpdateConditionRequest dto;
        dto.description = data.getString("description");
        dto.propertyKey = data.getString("propertyKey");
        dto.predicate = data.getString("predicate");
        dto.propertyValue = data.getString("propertyValue");
        dto.mandatory = data.getBool("mandatory", false);
        auto result = usecase.updateCondition(tenantId, id, dto);
        if (!result.success) {
            writeError(res, cast(int)HTTPStatus.notFound, result.message);
            return;
        }
        res.writeBody(result.message, cast(int)HTTPStatus.ok, "application/json");
    }

    private void handleDelete(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = req.requestPath.to!string.split("/")[$ - 1];
        auto result = usecase.deleteCondition(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Label deleted successfully", "Deleted", 200, responseData);
    }
}
