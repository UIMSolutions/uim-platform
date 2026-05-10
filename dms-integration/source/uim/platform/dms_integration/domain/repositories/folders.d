/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.repositories.folders;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

interface FolderRepository : ITenantRepository!(Folder, FolderId) {

    size_t countByRepository(TenantId tenantId, RepositoryId repositoryId);
    Folder[] findByRepository(TenantId tenantId, RepositoryId repositoryId);
    void removeByRepository(TenantId tenantId, RepositoryId repositoryId);

    Folder[] findByParent(TenantId tenantId, FolderId parentFolderId);
    Folder[] findByPath(TenantId tenantId, RepositoryId repositoryId, string path);
    Folder[] findRootFolders(TenantId tenantId, RepositoryId repositoryId);
}
