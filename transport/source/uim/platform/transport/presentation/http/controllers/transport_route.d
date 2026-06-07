/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.transport_route;

import uim.platform.transport;

// mixin(ShowModule!());

@safe:

class TransportRouteController : ManageHttpController {
    private ManageTransportRoutesUseCase usecase;

    this(ManageTransportRoutesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/transport/routes", &handleList);
        router.get("/api/v1/transport/routes/*", &handleGet);
        router.post("/api/v1/transport/routes", &handleCreate);
        router.put("/api/v1/transport/routes/*", &handleUpdate);
        router.delete_("/api/v1/transport/routes/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listRoutes(tenantId);
        auto list = items.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);
        return successResponse("Transport routes retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TransportRouteId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid route ID", 400);
            
        auto item = usecase.getRoute(tenantId, id);
        if (item.isNull)
            return errorResponse("Transport route not found", 404);

        auto responseData = item.toJson();
        return successResponse("Transport route retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        TransportRouteDTO dto;
        dto.routeId = TransportRouteId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.sourceNodeId = data.getString("sourceNodeId");
        dto.destinationNodeId = data.getString("destinationNodeId");
        dto.status = data.getString("status");
        dto.isSequential = data.getBoolean("isSequential");
        dto.sequence = cast(int)data.getLong("sequence");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createRoute(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Transport route created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TransportRouteId(precheck.id);
        auto data = precheck.data;
        auto action = data.getString("action");
        if (action == "enable") {
            auto result = usecase.enableRoute(tenantId, id);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto responseData = Json.emptyObject.set("id", result.id);
            return successResponse("Transport route enabled successfully", "Enabled", 200, responseData);
        }
        if (action == "disable") {
            auto result = usecase.disableRoute(tenantId, id);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto responseData = Json.emptyObject.set("id", result.id);
            return successResponse("Transport route disabled successfully", "Disabled", 200, responseData);
        }

        TransportRouteDTO dto;
        dto.routeId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.isSequential = data.getBoolean("isSequential");
        dto.sequence = data.getInteger("sequence");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateRoute(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Transport route updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TransportRouteId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid route ID", 400);  

        auto result = usecase.deleteRoute(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Transport route deleted successfully", "Deleted", 200, responseData);
    }
}
