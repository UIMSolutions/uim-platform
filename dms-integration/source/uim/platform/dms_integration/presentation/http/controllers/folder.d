/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.presentation.http.controllers.folder;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

class FolderController : PlatformController {
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

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
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
            auto jarr = items.map!(e => e.toJson).array.toJson;
            auto resp = Json.emptyObject.set("count", items.length).set("resources", jarr);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = FolderId(extractIdFromPath(path));
            auto item = usecase.getFolder(tenantId, id);
            if (item.isNull) { writeError(res, 404, "Folder not found"); return; }
            res.writeJsonBody(item.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            FolderDTO dto;
            dto.folderId = FolderId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.repositoryId = RepositoryId(j.getString("repositoryId"));
            dto.parentFolderId = FolderId(j.getString("parentFolderId"));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.path = j.getString("path");
            dto.depth = j.getInteger("depth");
            dto.folderType = j.getString("folderType");
            dto.isSystemFolder = j.getBool("isSystemFolder");
            dto.allowedDocumentTypes = j.getString("allowedDocumentTypes");
            dto.inheritPermissions = j.getBool("inheritPermissions");
            dto.isReadOnly = j.getBool("isReadOnly");
            dto.externalId = j.getString("externalId");
            dto.customProperties = j.getString("customProperties");
            dto.createdBy = UserId(j.getString("createdBy"));
            auto result = usecase.createFolder(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Folder created"), 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            auto action = j.getString("action");
            auto id = FolderId(extractIdFromPath(path));
            auto userId = UserId(j.getString("userId"));

            if (action == "move") {
                auto targetParentId = FolderId(j.getString("targetParentId"));
                auto result = usecase.moveFolder(tenantId, id, targetParentId, userId);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Folder moved"), 200);
                else writeError(res, 400, result.message);
                return;
            }

            FolderDTO dto;
            dto.folderId = id;
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.allowedDocumentTypes = j.getString("allowedDocumentTypes");
            dto.inheritPermissions = j.getBool("inheritPermissions");
            dto.customProperties = j.getString("customProperties");
            dto.updatedBy = userId;
            auto result = usecase.updateFolder(dto);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Folder updated"), 200);
            else writeError(res, 400, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = FolderId(extractIdFromPath(path));
            auto result = usecase.deleteFolder(tenantId, id);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Folder deleted"), 200);
            else writeError(res, 400, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
