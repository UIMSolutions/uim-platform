/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.application.usecases.manage.permissions;

import uim.platform.dms_integration;

// mixin(ShowModule!());

@safe:

class ManagePermissionsUseCase {
    private PermissionRepository repo;

    this(PermissionRepository repo) {
        this.repo = repo;
    }

    Permission getPermission(TenantId tenantId, PermissionId id) {
        return repo.find(tenantId, id);
    }

    Permission[] listPermissions(TenantId tenantId) {
        return repo.find(tenantId);
    }

    Permission[] listPermissionsByDocument(TenantId tenantId, DocumentId documentId) {
        return repo.findByDocument(tenantId, documentId);
    }

    Permission[] listPermissionsByFolder(TenantId tenantId, FolderId folderId) {
        return repo.findByFolder(tenantId, folderId);
    }

    Permission[] listPermissionsByPrincipal(TenantId tenantId, string principalId) {
        return repo.findByPrincipal(tenantId, principalId);
    }

    CommandResult grantPermission(PermissionDTO dto) {
        Permission perm;
        perm.id = dto.permissionId;
        perm.tenantId = dto.tenantId;
        perm.repositoryId = dto.repositoryId;
        perm.documentId = dto.documentId;
        perm.folderId = dto.folderId;
        perm.principalId = dto.principalId;
        perm.isInherited = dto.isInherited;
        perm.isDirect = dto.isDirect;
        perm.expiresAt = dto.expiresAt;
        perm.description = dto.description;
        perm.grantedBy = dto.grantedBy;
        perm.createdBy = dto.grantedBy;
        if (dto.principalType.length > 0) {
            
            try { perm.principalType = dto.principalType.to!PrincipalType; } catch (Exception) {}
        }
        if (dto.permissionType.length > 0) {
            
            try { perm.permissionType = dto.permissionType.to!PermissionType; } catch (Exception) {}
        }
        import std.datetime.systime : Clock;
        perm.grantedAt = currentTimestamp;
        if (!DmsValidator.isValidPermission(perm))
            return CommandResult(false, "", "Invalid permission: principalId and target (documentId or folderId) are required");
        repo.save(perm);
        return CommandResult(true, perm.id.value, "");
    }

    CommandResult revokePermission(TenantId tenantId, PermissionId id) {
        auto existing = repo.find(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Permission not found");
        if (existing.isInherited)
            return CommandResult(false, "", "Cannot revoke inherited permission directly");
        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deletePermission(TenantId tenantId, PermissionId id) {
        auto existing = repo.find(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Permission not found");
        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }
}
