/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.mesh_bridge;

import std.uuid : randomUUID;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

class MeshBridgeController : ManageHttpController {
    private ManageMeshBridgesUseCase usecase;

    this(ManageMeshBridgesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/event-mesh/bridges", &handleList);
        router.get("/api/v1/event-mesh/bridges/*", &handleGet);
        router.post("/api/v1/event-mesh/bridges", &handleCreate);
        router.put("/api/v1/event-mesh/bridges/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/bridges/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto bridges = usecase.listBridges(tenantId);
        auto jsBridges = bridges.map!(e => e.toJson()).array.toJson;

        auto resp = Json.emptyObject
            .set("count", bridges.length)
            .set("resources", jsBridges);

        return successResponse("Mesh bridge list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = MeshBridgeId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid mesh bridge ID", 400);

        auto e = usecase.getBridge(tenantId, id);
        if (e.isNull)
            return errorResponse("Mesh bridge not found", 404);

        auto responseData = e.toJson();
        return successResponse("Mesh bridge retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;

        auto createId = precheck.id;
        if (createId.isEmpty)
            createId = data.getString("id");
        if (createId.isEmpty) {
            try {
                createId = req.params["id"];
            } catch (Exception) {
            }
        }
        if (createId.isEmpty)
            createId = randomUUID().toString();

        MeshBridgeDTO dto;
        dto.bridgeId = MeshBridgeId(createId);
        dto.tenantId = tenantId;
        dto.sourceServiceId = BrokerServiceId(data.getString("sourceServiceId"));
        dto.targetServiceId = BrokerServiceId(data.getString("targetServiceId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.remoteAddress = data.getString("remoteAddress");
        dto.remoteVpnName = data.getString("remoteVpnName");
        dto.topicSubscriptions = data.getString("topicSubscriptions");
        dto.queueBindings = data.getString("queueBindings");
        dto.tlsEnabled = data.getString("tlsEnabled");
        dto.compressedDataEnabled = data.getString("compressedDataEnabled");
        dto.maxTtl = data.getString("maxTtl");
        dto.retryCount = data.getString("retryCount");
        dto.retryDelay = data.getString("retryDelay");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createBridge(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Mesh bridge created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        MeshBridgeDTO dto;
        dto.bridgeId = MeshBridgeId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.remoteAddress = data.getString("remoteAddress");
        dto.topicSubscriptions = data.getString("topicSubscriptions");
        dto.queueBindings = data.getString("queueBindings");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateBridge(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Mesh bridge updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = MeshBridgeId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid mesh bridge ID", 400);

        auto result = usecase.deleteBridge(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Mesh bridge deleted successfully", "Deleted", 200, responseData);
    }
}
