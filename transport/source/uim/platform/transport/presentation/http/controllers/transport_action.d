/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.transport_action;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class TransportActionController : ManageHttpController {
    private ManageTransportActionsUseCase usecase;

    this(ManageTransportActionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/transport/actions", &handleList);
        router.get("/api/v1/transport/actions/*", &handleGet);
        router.post("/api/v1/transport/actions", &handleCreate);
        router.put("/api/v1/transport/actions/*", &handleUpdate);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listActions(tenantId);
        auto list = items.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject.set("count", items.length).set("resources", list);
        return successResponse("Transport actions retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TransportActionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid action ID", 400);
            
        auto item = usecase.getAction(tenantId, id);
        if (item.isNull)
            return errorResponse("Transport action not found", 404);

        auto responseData = item.toJson();
        return successResponse("Transport action retrieved successfully", "Retrieved", 200, responseData);

    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        TransportActionDTO dto;
        dto.actionId = TransportActionId(precheck.id);
        dto.tenantId = tenantId;
        dto.actionType = data.getString("actionType");
        dto.nodeId = data.getString("nodeId");
        dto.requestId = data.getString("requestId");
        dto.routeId = data.getString("routeId");
        dto.performedBy = data.getString("performedBy");
        dto.description = data.getString("description");
        dto.logDetails = data.getString("logDetails");
        auto result = usecase.recordAction(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Transport action recorded successfully", "Recorded", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TransportActionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid action ID", 400);

        auto data = precheck.data;
        auto statusStr = data.getString("actionStatus");
        if (statusStr.length > 0) {
            auto status = statusStr.to!ActionStatus;
            auto errorMsg = data.getString("errorMessage");
            auto result = usecase.updateActionStatus(tenantId, id, status, errorMsg);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto responseData = Json.emptyObject.set("id", result.id);
            return successResponse("Action status updated successfully", "Updated", 200, responseData);

        }
        return errorResponse("No valid fields to update", 400);
    }
}
