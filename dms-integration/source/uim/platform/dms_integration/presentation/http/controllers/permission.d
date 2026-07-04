/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.presentation.http.controllers.permission;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

class PermissionController : ManageHttpController {
    private ManagePermissionsUseCase usecase;

    this(ManagePermissionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/dms-integration/permissions", &handleList);
        router.get("/api/v1/dms-integration/permissions/*", &handleGet);
        router.post("/api/v1/dms-integration/permissions", &handleCreate);
        router.delete_("/api/v1/dms-integration/permissions/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        Permission[] items;
        auto documentId = req.query.get("documentId", "");
        auto folderId = req.query.get("folderId", "");
        auto principalId = req.query.get("principalId", "");
        if (documentId.length > 0) {
            items = usecase.listPermissionsByDocument(tenantId, DocumentId(documentId));
        } else if (folderId.length > 0) {
            items = usecase.listPermissionsByFolder(tenantId, FolderId(folderId));
        } else if (principalId.length > 0) {
            items = usecase.listPermissionsByPrincipal(tenantId, principalId);
        } else {
            items = usecase.listPermissions(tenantId);
        }
        auto list = items.map!(e => e.toJson).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);
        return successResponse("Permission list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        PermissionDTO dto;
        dto.permissionId = PermissionId(precheck.id);
        dto.tenantId = tenantId;
        dto.repositoryId = RepositoryId(data.getString("repositoryId"));
        dto.documentId = DocumentId(data.getString("documentId"));
        dto.folderId = FolderId(data.getString("folderId"));
        dto.principalId = data.getString("principalId");
        dto.principalType = data.getString("principalType");
        dto.permissionType = data.getString("permissionType");
        dto.isInherited = data.getBoolean("isInherited");
        dto.isDirect = data.getBoolean("isDirect");
        dto.expiresAt = data.getLong("expiresAt");
        dto.description = data.getString("description");
        dto.grantedBy = UserId(data.getString("grantedBy"));

        auto result = usecase.grantPermission(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Permission granted successfully", "Created", 201, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = PermissionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid permission ID", 400);

        auto item = usecase.getPermission(tenantId, id);
        if (item.isNull)
            return errorResponse("Permission not found", 404);

        auto responseData = item.toJson();
        return successResponse("Permission retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = PermissionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid permission ID", 400);

        auto result = usecase.deletePermission(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Permission deleted successfully", "Deleted", 200, responseData);
    }
}
