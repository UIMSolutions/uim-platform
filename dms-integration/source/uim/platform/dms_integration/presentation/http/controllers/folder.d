/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.presentation.http.controllers.folder;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

class FolderController : ManageController {
    private ManageFoldersUseCase usecase;

    this(ManageFoldersUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/dms-integration/folders", &handleList);
        router.get("/api/v1/dms-integration/folders/*", &handleGet);
        router.post("/api/v1/dms-integration/folders", &handleCreate);
        router.put("/api/v1/dms-integration/folders/*", &handleUpdate);
        router.delete_("/api/v1/dms-integration/folders/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        Folder[] items;
        auto parentId = req.query.get("parentId", "");
        auto repositoryId = req.query.get("repositoryId", "");
        if (parentId.length > 0) {
            items = usecase.listSubFolders(tenantId, FolderId(parentId));
        } else if (repositoryId.length > 0) {
            items = usecase.listRootFolders(tenantId, RepositoryId(repositoryId));
        } else {
            items = usecase.listFolders(tenantId);
        }
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Folder list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        FolderDTO dto;
        dto.folderId = FolderId(precheck.id);
        dto.tenantId = tenantId;
        dto.repositoryId = RepositoryId(data.getString("repositoryId"));
        dto.parentFolderId = FolderId(data.getString("parentFolderId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.path = data.getString("path");
        dto.depth = data.getInteger("depth");
        dto.folderType = data.getString("folderType");
        dto.isSystemFolder = data.getBoolean("isSystemFolder");
        dto.allowedDocumentTypes = data.getString("allowedDocumentTypes");
        dto.inheritPermissions = data.getBoolean("inheritPermissions");
        dto.isReadOnly = data.getBoolean("isReadOnly");
        dto.externalId = data.getString("externalId");
        dto.customProperties = data.getString("customProperties");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createFolder(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Folder created successfully", "Created", 201, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = FolderId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid folder ID", 400);

        auto item = usecase.getFolder(tenantId, id);
        if (item.isNull)
            return errorResponse("Folder not found", 404);

        auto responseData = item.toJson();
        return successResponse("Folder retrieved successfully", "Retrieved", 200, responseData);

    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = FolderId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid folder ID", 400);

        auto data = precheck.data;
        auto userId = UserId(data.getString("userId"));
        auto action = data.getString("action");

        if (action == "move") {
            auto targetParentId = FolderId(data.getString("targetParentId"));
            auto result = usecase.moveFolder(tenantId, id, targetParentId, userId);
            if (result.hasError)
                return errorResponse(result.message, 400);

            auto responseData = Json.emptyObject.set("id", result.id);
            return successResponse("Folder moved successfully", "Moved", 200, responseData);
        }

        FolderDTO dto;
        dto.folderId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.allowedDocumentTypes = data.getString("allowedDocumentTypes");
        dto.inheritPermissions = data.getBoolean("inheritPermissions");
        dto.customProperties = data.getString("customProperties");
        dto.updatedBy = userId;

        auto result = usecase.updateFolder(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Folder updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = FolderId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid folder ID", 400);

        auto result = usecase.deleteFolder(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Folder deleted successfully", "Deleted", 200, responseData);
    }
}
