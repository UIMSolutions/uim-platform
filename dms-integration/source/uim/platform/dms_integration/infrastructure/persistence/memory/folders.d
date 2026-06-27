/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.infrastructure.persistence.memory.folders;

import uim.platform.dms_integration;

// mixin(ShowModule!());

@safe:

class MemoryFolderRepository : TenantRepository!(Folder, FolderId), FolderRepository {

    size_t countByRepository(TenantId tenantId, RepositoryId repositoryId) {
        return findByRepository(tenantId, repositoryId).length;
    }
    Folder[] findByRepository(TenantId tenantId, RepositoryId repositoryId) {
        return findByTenant(tenantId).filter!(e => e.repositoryId == repositoryId).array;
    }
    void removeByRepository(TenantId tenantId, RepositoryId repositoryId) {
        findByRepository(tenantId, repositoryId).each!(e => remove(e));
    }

    Folder[] findByParent(TenantId tenantId, FolderId parentFolderId) {
        return findByTenant(tenantId).filter!(e => e.parentFolderId == parentFolderId).array;
    }

    Folder[] findByPath(TenantId tenantId, RepositoryId repositoryId, string path) {
        return findByRepository(tenantId, repositoryId).filter!(e => e.path == path).array;
    }

    Folder[] findRootFolders(TenantId tenantId, RepositoryId repositoryId) {
        return findByRepository(tenantId, repositoryId).filter!(e => e.depth == 0).array;
    }
}
