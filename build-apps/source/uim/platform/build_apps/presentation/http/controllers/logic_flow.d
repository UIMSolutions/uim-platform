/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.logic_flow;

import uim.platform.build_apps;

// mixin(ShowModule!());

@safe:

class LogicFlowController : ManageHttpController {
    private ManageLogicFlowsUseCase usecase;

    this(ManageLogicFlowsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/build-apps/logic-flows", &handleList);
        router.get("/api/v1/build-apps/logic-flows/*", &handleGet);
        router.post("/api/v1/build-apps/logic-flows", &handleCreate);
        router.put("/api/v1/build-apps/logic-flows/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/logic-flows/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listLogicFlows(tenantId);
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Logic flow list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = LogicFlowId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid logic flow ID", 400);

        auto flow = usecase.getLogicFlow(tenantId, id);
        if (flow.isNull)
            return errorResponse("Logic flow not found", 404);

        auto responseData = flow.toJson();
        return successResponse("Logic flow retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        LogicFlowDTO dto;
        dto.logicFlowId = LogicFlowId(precheck.id);
        dto.tenantId = tenantId;
        dto.applicationId = ApplicationId(data.getString("applicationId"));
        dto.pageId = PageId(data.getString("pageId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.trigger = data.getString("trigger");
        dto.triggerConfig = data.getString("triggerConfig");
        dto.nodes = data.getString("nodes");
        dto.connections = data.getString("connections");
        dto.variables = data.getString("variables");
        dto.errorHandler = data.getString("errorHandler");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createLogicFlow(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Logic flow created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        LogicFlowDTO dto;
        dto.tenantId = tenantId;
        dto.logicFlowId = LogicFlowId(precheck.id);
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.nodes = data.getString("nodes");
        dto.connections = data.getString("connections");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateLogicFlow(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Logic flow updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = LogicFlowId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid logic flow ID", 400);

        auto result = usecase.deleteLogicFlow(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Logic flow deleted successfully", "Deleted", 200, responseData);
    }
}
