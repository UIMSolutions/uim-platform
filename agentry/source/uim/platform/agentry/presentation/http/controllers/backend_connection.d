/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.backend_connection;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class BackendConnectionController : ManageController {
    private ManageBackendConnectionsUseCase usecase;

    this(ManageBackendConnectionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/agentry/backend-connections", &handleList);
        router.get("/api/v1/agentry/backend-connections/*", &handleGet);
        router.post("/api/v1/agentry/backend-connections", &handleCreate);
        router.put("/api/v1/agentry/backend-connections/*", &handleUpdate);
        router.delete_("/api/v1/agentry/backend-connections/*", &handleDelete);
    }

   override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listBackendConnections(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr);

        return successResponse("Backend connection list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = BackendConnectionId(precheck.id);
            auto e = usecase.getBackendConnection(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Backend connection not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            BackendConnectionDTO dto;
            dto.connectionId = BackendConnectionId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.backendUrl = j.getString("backendUrl");
            dto.clientId = j.getString("clientId");
            dto.authMethod = j.getString("authMethod");
            dto.sysId = j.getString("sysId");
            dto.sysNumber = j.getString("sysNumber");
            dto.client = j.getString("client");
            dto.language = j.getString("language");
            dto.destinationName = j.getString("destinationName");
            dto.sslEnabled = j.getBool("sslEnabled");
            dto.certificateFingerprint = j.getString("certificateFingerprint");

            auto result = usecase.createBackendConnection(dto);
            if (!result.success) { writeError(res, 400, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Backend connection created successfully");
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
            BackendConnectionDTO dto;
            dto.connectionId = BackendConnectionId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.backendUrl = j.getString("backendUrl");
            dto.destinationName = j.getString("destinationName");

            auto result = usecase.updateBackendConnection(dto);
            if (!result.success) { writeError(res, 404, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Backend connection updated successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = BackendConnectionId(precheck.id);
            auto result = usecase.deleteBackendConnection(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "Backend connection deleted successfully"), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
