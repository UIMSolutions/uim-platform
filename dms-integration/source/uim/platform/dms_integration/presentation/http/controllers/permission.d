/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.presentation.http.controllers.permission;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

class PermissionController : PlatformController {
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

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
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
            auto jarr = items.map!(e => e.toJson).array.toJson;
            auto resp = Json.emptyObject.set("count", items.length).set("resources", jarr);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = PermissionId(extractIdFromPath(path));
            auto item = usecase.getPermission(tenantId, id);
            if (item.isNull) { writeError(res, 404, "Permission not found"); return; }
            res.writeJsonBody(item.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            PermissionDTO dto;
            dto.permissionId = PermissionId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.repositoryId = RepositoryId(j.getString("repositoryId"));
            dto.documentId = DocumentId(j.getString("documentId"));
            dto.folderId = FolderId(j.getString("folderId"));
            dto.principalId = j.getString("principalId");
            dto.principalType = j.getString("principalType");
            dto.permissionType = j.getString("permissionType");
            dto.isInherited = j.getBool("isInherited");
            dto.isDirect = j.getBool("isDirect");
            dto.expiresAt = j.getString("expiresAt");
            dto.description = j.getString("description");
            dto.grantedBy = UserId(j.getString("grantedBy"));
            auto result = usecase.grantPermission(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Permission granted"), 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = PermissionId(extractIdFromPath(path));
            auto result = usecase.deletePermission(tenantId, id);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Permission revoked"), 200);
            else writeError(res, 404, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
