/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.extension;

import uim.platform.application_studio;

// mixin(ShowModule!());

@safe:

class ExtensionController : ManageHttpController {
    private ManageExtensionsUseCase usecase;

    this(ManageExtensionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/application-studio/extensions", &handleList);
        router.get("/api/v1/application-studio/extensions/*", &handleGet);
        router.post("/api/v1/application-studio/extensions", &handleCreate);
        router.put("/api/v1/application-studio/extensions/*", &handleUpdate);
        router.delete_("/api/v1/application-studio/extensions/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listExtensions(tenantId);
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Extension list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ExtensionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid extension ID", 400);

        auto extension = usecase.getExtension(tenantId, id);
        if (extension.isNull)
            return errorResponse("Extension not found", 404);

        auto responseData = extension.toJson();
        return successResponse("Extension retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ExtensionDTO dto;
        dto.extensionId = ExtensionId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.version_ = data.getString("version");
        dto.publisher = data.getString("publisher");
        dto.category = data.getString("category");
        dto.dependencies = data.getString("dependencies");
        dto.capabilities = data.getString("capabilities");
        dto.iconUrl = data.getString("iconUrl");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createExtension(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Extension created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ExtensionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid extension ID", 400);

        auto data = precheck.data;
        ExtensionDTO dto;
        dto.extensionId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.version_ = data.getString("version");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateExtension(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Extension updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ExtensionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid extension ID", 400);

        auto result = usecase.deleteExtension(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Extension deleted successfully", "Deleted", 200, responseData);
    }
}
