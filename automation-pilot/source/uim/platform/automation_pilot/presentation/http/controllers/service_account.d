/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.service_account;

import uim.platform.automation_pilot;

// mixin(ShowModule!());

@safe:

class ServiceAccountController : ManageHttpController {
    private ManageServiceAccountsUseCase usecase;

    this(ManageServiceAccountsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/automation-pilot/service-accounts", &handleList);
        router.get("/api/v1/automation-pilot/service-accounts/*", &handleGet);
        router.post("/api/v1/automation-pilot/service-accounts", &handleCreate);
        router.put("/api/v1/automation-pilot/service-accounts/*", &handleUpdate);
        router.delete_("/api/v1/automation-pilot/service-accounts/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listServiceAccounts(tenantId);
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Service account list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ServiceAccountId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service account ID", 400);

        auto account = usecase.getServiceAccount(tenantId, id);
        if (account.isNull)
            return errorResponse("Service account not found", 404);

        auto responseData = account.toJson();
        return successResponse("Service account retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ServiceAccountDTO dto;
        dto.tenantId = tenantId;
        dto.serviceAccountId = ServiceAccountId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.clientId = data.getString("clientId");
        dto.permissions = data.getString("permissions");
        dto.expiresAt = data.getLong("expiresAt");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createServiceAccount(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service account created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ServiceAccountDTO dto;
        dto.tenantId = tenantId;
        dto.serviceAccountId = ServiceAccountId(precheck.id);
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.permissions = data.getString("permissions");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateServiceAccount(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service account updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ServiceAccountId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service account ID", 400);

        auto result = usecase.deleteServiceAccount(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service account deleted successfully", "Deleted", 200, responseData);
    }
}
