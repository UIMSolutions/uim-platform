/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.sync_session;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class SyncSessionController : PlatformController {
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

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listSyncSessions(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Sync session list retrieved successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = SyncSessionId(extractIdFromPath(path));
            auto e = usecase.getSyncSession(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Sync session not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            SyncSessionDTO dto;
            dto.syncSessionId = SyncSessionId(j.getString("id"));
            dto.deviceId = DeviceId(j.getString("deviceId"));
            dto.mobileApplicationId = MobileApplicationId(j.getString("mobileApplicationId"));
            dto.backendConnectionId = BackendConnectionId(j.getString("backendConnectionId"));
            dto.tenantId = tenantId;
            dto.triggeredBy = j.getString("triggeredBy");
            dto.clientAppVersion = j.getString("clientAppVersion");

            auto result = usecase.createSyncSession(dto);
            if (!result.success) { writeError(res, 400, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Sync session created successfully");
            res.writeJsonBody(resp, 201);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            SyncSessionDTO dto;
            dto.syncSessionId = SyncSessionId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.status = j.getString("status");

            auto result = usecase.updateSyncSession(dto);
            if (!result.success) { writeError(res, 404, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Sync session updated successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = SyncSessionId(extractIdFromPath(path));
            auto result = usecase.deleteSyncSession(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "Sync session deleted successfully"), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
