/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.data_entity;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class DataEntityController : ManageHttpController {
    private ManageDataEntitiesUseCase usecase;

    this(ManageDataEntitiesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/build-apps/data-entities", &handleList);
        router.get("/api/v1/build-apps/data-entities/*", &handleGet);
        router.post("/api/v1/build-apps/data-entities", &handleCreate);
        router.put("/api/v1/build-apps/data-entities/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/data-entities/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listDataEntities(tenantId);
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Data entity list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataEntityId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid data entity ID", 400);

        auto e = usecase.getDataEntity(tenantId, id);
        if (e.isNull)
            return errorResponse("Data entity not found", 404);

        auto responseData = e.toJson();
        return successResponse("Data entity retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        DataEntityDTO dto;
        dto.dataEntityId = DataEntityId(precheck.id);
        dto.tenantId = precheck.tenantId;
        dto.applicationId = ApplicationId(data.getString("applicationId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.fields = data.getString("fields");
        dto.primaryKey = data.getString("primaryKey");
        dto.indexes = data.getString("indexes");
        dto.validationRules = data.getString("validationRules");
        dto.defaultValues = data.getString("defaultValues");
        dto.relations = data.getString("relations");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createDataEntity(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Data entity created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataEntityId(precheck.id);

        auto data = precheck.data;
        DataEntityDTO dto;
        dto.tenantId = precheck.tenantId;
        dto.dataEntityId = id;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.fields = data.getString("fields");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateDataEntity(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Data entity updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataEntityId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid data entity ID", 400);

        auto result = usecase.deleteDataEntity(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Data entity deleted successfully", "Deleted", 200, responseData);
    }
}
