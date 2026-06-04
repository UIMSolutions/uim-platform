/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.presentation.http.controllers.repository_;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

class RepositoryController : ManageHttpController {
    private ManageRepositoriesUseCase usecase;

    this(ManageRepositoriesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/dms-integration/repositories", &handleList);
        router.get("/api/v1/dms-integration/repositories/*", &handleGet);
        router.post("/api/v1/dms-integration/repositories", &handleCreate);
        router.put("/api/v1/dms-integration/repositories/*", &handleUpdate);
        router.delete_("/api/v1/dms-integration/repositories/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listRepositories(tenantId);
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Repository list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        RepositoryDTO dto;
        dto.repositoryId = RepositoryId(precheck.id);
        dto.tenantId = precheck.tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.repositoryType = data.getString("repositoryType");
        dto.externalUrl = data.getString("externalUrl");
        dto.cmisVersion = data.getString("cmisVersion");
        dto.encryptionEnabled = data.getBoolean("encryptionEnabled");
        dto.capacityLimitBytes = data.getLong("capacityLimitBytes");
        dto.repositoryKey = data.getString("repositoryKey");
        dto.externalRepositoryId = data.getString("externalRepositoryId");
        dto.region = data.getString("region");
        dto.isDefault = data.getBoolean("isDefault");
        dto.isReadOnly = data.getBoolean("isReadOnly");
        dto.versioningEnabled = data.getBoolean("versioningEnabled");
        dto.fullTextSearchEnabled = data.getBoolean("fullTextSearchEnabled");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createRepository(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Repository created successfully", "Created", 201, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = RepositoryId(precheck.id);
        auto item = usecase.getRepository(tenantId, id);
        if (item.isNull)
            return errorResponse("Repository not found", 404);

        auto responseData = item.toJson();
        return successResponse("Repository retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = RepositoryId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid repository ID", 400);

        auto data = precheck.data;
        auto action = data.getString("action");
        switch (action) {
        case "activate":
            auto result = usecase.activateRepository(tenantId, id);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto responseData = Json.emptyObject.set("id", result.id);
            return successResponse("Repository updated successfully", "Updated", 200, responseData);

        case "deactivate":
            auto result = usecase.deactivateRepository(tenantId, id);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto responseData = Json.emptyObject.set("id", result.id);
            return successResponse("Repository updated successfully", "Updated", 200, responseData);
        default:
            RepositoryDTO dto;
            dto.repositoryId = id;
            dto.tenantId = precheck.tenantId;
            dto.name = data.getString(
                "name");
            dto.description = data.getString("description");
            dto.externalUrl = data.getString(
                "externalUrl");
            dto.region = data.getString("region");
            dto.isDefault = data.getBoolean(
                "isDefault");
            dto.isReadOnly = data.getBoolean("isReadOnly");
            dto.versioningEnabled = data.getBoolean(
                "versioningEnabled");
            dto.fullTextSearchEnabled = data.getBoolean("fullTextSearchEnabled");
            dto.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateRepository(dto);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto responseData = Json.emptyObject.set("id", result.id);
            return successResponse("Repository updated successfully", "Updated", 200, responseData);
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = RepositoryId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid repository ID", 400);

        auto result = usecase.deleteRepository(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Repository deleted successfully", "Deleted", 200, responseData);
    }
}
