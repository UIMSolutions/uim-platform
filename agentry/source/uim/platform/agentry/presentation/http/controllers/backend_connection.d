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

        auto connections = usecase.listBackendConnections(tenantId);
        auto jsConnections = connections.map!(e => e.toJson()).array.toJson;
        auto resp = Json.emptyObject
            .set("count", connections.length)
            .set("resources", jsConnections);

        return successResponse("Backend connection list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = BackendConnectionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid backend connection ID", 400);

        auto e = usecase.getBackendConnection(tenantId, id);
        if (e.isNull)
            return errorResponse("Backend connection not found", 404);

        auto responseData = e.toJson();
        return successResponse("Backend connection retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        BackendConnectionDTO dto;
        dto.connectionId = BackendConnectionId(data.getString("id"));
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.backendUrl = data.getString("backendUrl");
        dto.clientId = data.getString("clientId");
        dto.authMethod = data.getString("authMethod");
        dto.sysId = data.getString("sysId");
        dto.sysNumber = data.getString("sysNumber");
        dto.client = data.getString("client");
        dto.language = data.getString("language");
        dto.destinationName = data.getString("destinationName");
        dto.sslEnabled = data.getBoolean("sslEnabled");
        dto.certificateFingerprint = data.getString("certificateFingerprint");

        auto result = usecase.createBackendConnection(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Backend connection created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = BackendConnectionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid backend connection ID", 400);

        auto data = precheck.data;
        BackendConnectionDTO dto;
        dto.connectionId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.backendUrl = data.getString("backendUrl");
        dto.destinationName = data.getString("destinationName");

        auto result = usecase.updateBackendConnection(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", id);
        return successResponse("Backend connection updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = BackendConnectionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid backend connection ID", 400);

        auto result = usecase.deleteBackendConnection(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Backend connection deleted successfully", "Deleted", 200, responseData);
    }
}
