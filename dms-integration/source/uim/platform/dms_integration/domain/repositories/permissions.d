/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.repositories.permissions;

import uim.platform.dms_integration;
mixin(ShowModule!());

@safe:

interface PermissionRepository : ITenantRepository!(Permission, PermissionId) {

    Permission[] findByDocument(TenantId tenantId, DocumentId documentId);
    void removeByDocument(TenantId tenantId, DocumentId documentId);

    Permission[] findByFolder(TenantId tenantId, FolderId folderId);
    void removeByFolder(TenantId tenantId, FolderId folderId);

    Permission[] findByPrincipal(TenantId tenantId, string principalId);
    Permission[] findByRepository(TenantId tenantId, RepositoryId repositoryId);
}
