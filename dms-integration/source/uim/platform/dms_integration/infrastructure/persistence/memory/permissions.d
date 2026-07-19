/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.infrastructure.persistence.memory.permissions;

import uim.platform.dms_integration;
mixin(ShowModule!());

@safe:

class MemoryPermissionRepository : TenantRepository!(Permission, PermissionId), PermissionRepository {

    Permission[] findByDocument(TenantId tenantId, DocumentId documentId) {
        return findByTenant(tenantId).filter!(e => e.documentId == documentId).array;
    }
    void removeByDocument(TenantId tenantId, DocumentId documentId) {
        findByDocument(tenantId, documentId).each!(e => remove(e));
    }

    Permission[] findByFolder(TenantId tenantId, FolderId folderId) {
        return findByTenant(tenantId).filter!(e => e.folderId == folderId).array;
    }
    void removeByFolder(TenantId tenantId, FolderId folderId) {
        findByFolder(tenantId, folderId).each!(e => remove(e));
    }

    Permission[] findByPrincipal(TenantId tenantId, string principalId) {
        return findByTenant(tenantId).filter!(e => e.principalId == principalId).array;
    }

    Permission[] findByRepository(TenantId tenantId, RepositoryId repositoryId) {
        return findByTenant(tenantId).filter!(e => e.repositoryId == repositoryId).array;
    }
}
