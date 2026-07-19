/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.dev_space_type;

import uim.platform.application_studio;
mixin(ShowModule!());

@safe:

class DevSpaceTypeController : ManageHttpController {
    private ManageDevSpaceTypesUseCase usecase;

    this(ManageDevSpaceTypesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/application-studio/dev-space-types", &handleList);
        router.get("/api/v1/application-studio/dev-space-types/*", &handleGet);
        router.post("/api/v1/application-studio/dev-space-types", &handleCreate);
        router.put("/api/v1/application-studio/dev-space-types/*", &handleUpdate);
        router.delete_("/api/v1/application-studio/dev-space-types/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listDevSpaceTypes(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Dev space type list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        DevSpaceTypeDTO dto;
        dto.typeId = DevSpaceTypeId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.predefinedExtensions = data.getString("predefinedExtensions");
        dto.supportedProjectTypes = data.getString("supportedProjectTypes");
        dto.runtimeStack = data.getString("runtimeStack");
        dto.iconUrl = data.getString("iconUrl");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createDevSpaceType(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Dev space type created successfully", "Created", 201, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DevSpaceTypeId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid dev space type ID", 400);

        auto e = usecase.getDevSpaceType(tenantId, id);
        if (e.isNull)
            return errorResponse("Dev space type not found", 404);

        return successResponse("Dev space type retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        DevSpaceTypeDTO dto;
        dto.tenantId = tenantId;
        dto.typeId = DevSpaceTypeId(precheck.id);
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.predefinedExtensions = data.getString("predefinedExtensions");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateDevSpaceType(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Dev space type updated successfully", "Updated", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = DevSpaceTypeId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid dev space type ID", 400);

        auto result = usecase.deleteDevSpaceType(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Dev space type deleted successfully", "Deleted", 200, resp);
    }
}
