/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.sync_session;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class SyncSessionController : ManageHttpController {
    private ManageSyncSessionsUseCase usecase;

    this(ManageSyncSessionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/agentry/sync-sessions", &handleList);
        router.get("/api/v1/agentry/sync-sessions/*", &handleGet);
        router.post("/api/v1/agentry/sync-sessions", &handleCreate);
        router.put("/api/v1/agentry/sync-sessions/*", &handleUpdate);
        router.delete_("/api/v1/agentry/sync-sessions/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listSyncSessions(tenantId);
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);
        return successResponse("Sync session list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = SyncSessionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid sync session ID", 400);

        auto ses = usecase.getSyncSession(tenantId, id);
        if (ses.isNull)
            return errorResponse("Sync session not found", 404);

        auto responseData = ses.toJson();
        return successResponse("Sync session retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        SyncSessionDTO dto;
        dto.sessionId = SyncSessionId(precheck.id);
        dto.deviceId = DeviceId(data.getString("deviceId"));
        dto.applicationId = MobileApplicationId(data.getString("applicationId"));
        dto.connectionId = BackendConnectionId(data.getString("connectionId"));
        dto.tenantId = tenantId;
        dto.triggeredBy = data.getString("triggeredBy");
        dto.clientAppVersion = data.getString("clientAppVersion");

        auto result = usecase.createSyncSession(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Sync session created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        SyncSessionDTO dto;
        dto.sessionId = SyncSessionId(precheck.id);
        dto.tenantId = tenantId;
        dto.status = data.getString("status");

        auto result = usecase.updateSyncSession(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Sync session updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = SyncSessionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid sync session ID", 400);

        auto result = usecase.deleteSyncSession(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Sync session deleted successfully", "Deleted", 200, responseData);
    }
}
