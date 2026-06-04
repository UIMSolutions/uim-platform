/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.content_connector;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ContentConnectorController : ManageHttpController {
    private ManageContentConnectorsUseCase usecase;

    this(ManageContentConnectorsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/automation-pilot/content-connectors", &handleList);
        router.get("/api/v1/automation-pilot/content-connectors/*", &handleGet);
        router.post("/api/v1/automation-pilot/content-connectors", &handleCreate);
        router.put("/api/v1/automation-pilot/content-connectors/*", &handleUpdate);
        router.delete_("/api/v1/automation-pilot/content-connectors/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listContentConnectors(tenantId);
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Content connector list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ContentConnectorId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid content connector ID", 400);

        auto connector = usecase.getContentConnector(tenantId, id);
        if (connector.isNull)
            return errorResponse("Content connector not found", 404);

        auto responseData = connector.toJson();
        return successResponse("Content connector retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ContentConnectorDTO dto;
        dto.contentConnectorId = ContentConnectorId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.repositoryUrl = data.getString("repositoryUrl");
        dto.branch = data.getString("branch");
        dto.path = data.getString("path");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createContentConnector(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Content connector created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ContentConnectorId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid content connector ID", 400);

        auto data = precheck.data;
        ContentConnectorDTO dto;
        dto.connectorId = id;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.repositoryUrl = data.getString("repositoryUrl");
        dto.branch = data.getString("branch");
        dto.path = data.getString("path");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateContentConnector(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Content connector updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ContentConnectorId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid content connector ID", 400);

        auto result = usecase.deleteContentConnector(tenantId, contentConnectorId);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Content connector deleted successfully", "Deleted", 200, responseData);
    }
}
