/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.data_connection;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class DataConnectionController : ManageController {
    private ManageDataConnectionsUseCase usecase;

    this(ManageDataConnectionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/build-apps/data-connections", &handleList);
        router.get("/api/v1/build-apps/data-connections/*", &handleGet);
        router.post("/api/v1/build-apps/data-connections", &handleCreate);
        router.put("/api/v1/build-apps/data-connections/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/data-connections/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listConnections(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Data connection list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataConnectionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid data connection ID", 400);

        auto connection = usecase.getDataConnection(tenantId, id);
        if (connection.isNull)
            return errorResponse("Data connection not found", 404);

        auto responseData = connection.toJson();
        return successResponse("Data connection retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataConnectionId(precheck.id);

        auto data = precheck.data;
        DataConnectionDTO dto;
        dto.tenantId = tenantId;
        dto.dataConnectionId = id;
        dto.applicationId = ApplicationId(data.getString("applicationId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.connectionType = data.getString("connectionType");
        dto.authMethod = data.getString("authMethod");
        dto.baseUrl = data.getString("baseUrl");
        dto.basePath = data.getString("basePath");
        dto.headers = data.getString("headers");
        dto.queryParams = data.getString("queryParams");
        dto.responseMapping = data.getString("responseMapping");
        dto.destinationName = data.getString("destinationName");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createDataConnection(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Data connection created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        DataConnectionDTO dto;
        dto.dataConnectionId = DataConnectionId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.baseUrl = data.getString("baseUrl");
        dto.basePath = data.getString("basePath");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateDataConnection(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Data connection updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataConnectionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid data connection ID", 400);

        auto result = usecase.deleteDataConnection(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Data connection deleted successfully", "Deleted", 200, responseData);
    }
}
