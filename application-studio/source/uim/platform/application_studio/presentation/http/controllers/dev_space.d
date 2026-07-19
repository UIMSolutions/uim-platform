/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.dev_space;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class DevSpaceController : ManageHttpController {
    private ManageDevSpacesUseCase usecase;

    this(ManageDevSpacesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/application-studio/dev-spaces", &handleList);
        router.get("/api/v1/application-studio/dev-spaces/*", &handleGet);
        router.post("/api/v1/application-studio/dev-spaces", &handleCreate);
        router.put("/api/v1/application-studio/dev-spaces/*", &handleUpdate);
        router.delete_("/api/v1/application-studio/dev-spaces/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listDevSpaces(tenantId);
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);
        return successResponse("Dev space list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = DevSpaceId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid dev space ID", 400);

        auto space = usecase.getDevSpace(tenantId, id);
        if (space.isNull)
            return errorResponse("Scan job not found", 404);

        auto responseData = space.toJson();
        return successResponse("Dev space retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DevSpaceId(precheck.id);

        auto data = precheck.data;
        DevSpaceDTO dto;
        dto.spaceId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.typeId = DevSpaceTypeId(data.getString("devSpaceTypeId"));
        dto.extensions = data.getString("extensions");
        dto.owner = data.getString("owner");
        dto.region = data.getString("region");
        dto.hibernateAfterDays = data.getString("hibernateAfterDays");
        dto.memoryLimit = data.getString("memoryLimit");
        dto.diskLimit = data.getString("diskLimit");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createDevSpace(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Dev space created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DevSpaceId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid dev space ID", 400);

        auto data = precheck.data;
        DevSpaceDTO dto;
        dto.spaceId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.extensions = data.getString("extensions");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateDevSpace(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Dev space updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = DevSpaceId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid dev space ID", 400);

        auto result = usecase.deleteDevSpace(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Dev space deleted successfully", "Deleted", 200, responseData);
    }
}
