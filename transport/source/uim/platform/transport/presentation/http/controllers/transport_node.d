/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.transport_node;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class TransportNodeController : ManageHttpController {
    private ManageTransportNodesUseCase usecase;

    this(ManageTransportNodesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/transport/nodes", &handleList);
        router.get("/api/v1/transport/nodes/*", &handleGet);
        router.post("/api/v1/transport/nodes", &handleCreate);
        router.put("/api/v1/transport/nodes/*", &handleUpdate);
        router.delete_("/api/v1/transport/nodes/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listNodes(tenantId);
        auto list = items.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject.set("count", items.length).set("resources", list);
        return successResponse("Transport nodes retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TransportNodeId(precheck.id);
        auto item = usecase.getNode(tenantId, id);
        if (item.isNull)
            return errorResponse("Transport node not found", 404);

        auto responseData = item.toJson();
        return successResponse("Transport node retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        TransportNodeDTO dto;
        dto.nodeId = TransportNodeId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.nodeType = data.getString("nodeType");
        dto.environment = data.getString("environment");
        dto.region = data.getString("region");
        dto.globalAccount = data.getString("globalAccount");
        dto.subaccountId = data.getString("subaccountId");
        dto.spaceId = data.getString("spaceId");
        dto.serviceKey = data.getString("serviceKey");
        dto.isForwardEnabled = data.getBoolean("isForwardEnabled");
        dto.autoImport = data.getBoolean("autoImport");
        dto.autoImportSchedule = data.getString("autoImportSchedule");
        dto.createdBy = UserId(data.getString("createdBy"));
        auto result = usecase.createNode(dto);

        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Transport node created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TransportNodeId(precheck.id);
        auto data = precheck.data;
        auto action = data.getString("action");
        if (action == "enable") {
            auto result = usecase.enableNode(tenantId, id);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto responseData = Json.emptyObject.set("id", result.id);
            return successResponse("Transport node enabled successfully", "Enabled", 200, responseData);
        }
        if (action == "disable") {
            auto result = usecase.disableNode(tenantId, id);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto responseData = Json.emptyObject.set("id", result.id);
            return successResponse("Transport node disabled successfully", "Disabled", 200, responseData);
        }
        TransportNodeDTO dto;
        dto.nodeId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.region = data.getString("region");
        dto.environment = data.getString("environment");
        dto.isForwardEnabled = data.getBoolean("isForwardEnabled");
        dto.autoImport = data.getBoolean("autoImport");
        dto.autoImportSchedule = data.getString("autoImportSchedule");
        dto.updatedBy = UserId(data.getString("updatedBy"));
        auto result = usecase.updateNode(dto);

        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Transport node updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TransportNodeId(precheck.id);
        auto result = usecase.deleteNode(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Transport node deleted successfully", "Deleted", 200, responseData);
    }
}
